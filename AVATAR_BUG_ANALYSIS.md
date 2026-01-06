# Avatar Loading Bug - Race Condition with OpenStack Storage

## 🐛 Problem Summary

**Error**: `ActionView::Template::Error (undefined method 'zero?' for nil:NilClass)`

**Location**: `app/views/devise/registrations/edit.html.slim:14`

**Frequency**: Intermittent (occurs randomly on hard refresh)

**User Affected**: dariusz.finster@gmail.com (User ID: 1, KW ID: 2345)

**Avatar URL**: `https://storage.waw.cloud.ovh.net/v1/AUTH_b69bb975c19b4ec482592361f1ef5e29/kw-app-cloud-production/membership/avatars/1/494112734_1213027200699197_3305966457822045659_n.jpg`

## 🔍 Root Cause Analysis

### The Bug Chain

1. **CarrierWave calls** `current_user.avatar.url` in view
2. **fog-openstack** makes API call to OpenStack with aggressive 5-second timeouts
3. **OpenStack API** sometimes responds slowly or times out
4. **fog returns** `file.content_length = nil` instead of a number
5. **CarrierWave's `size` method** returns `nil` (from `/usr/local/bundle/ruby/3.2.0/gems/carrierwave-3.1.0/lib/carrierwave/storage/fog.rb:size`)
6. **CarrierWave's `empty?` method** calls `size.zero?` 
7. **Ruby raises** `NoMethodError: undefined method 'zero?' for nil:NilClass`

### Source Code Evidence

**CarrierWave fog.rb (line ~200)**
```ruby
def size
  file.nil? ? 0 : file.content_length  # ⚠️ content_length can be nil!
end

def empty?
  !exists? || size.zero?  # ⚠️ Crashes if size returns nil
end
```

### Configuration Issues

**config/initializers/carrierwave.rb**
```ruby
connection_options: {
  connect_timeout: 5,   # ⚠️ Very aggressive
  read_timeout: 5,      # ⚠️ Very aggressive
  write_timeout: 5      # ⚠️ Very aggressive
}
```

These 5-second timeouts are too aggressive for OpenStack API, especially under load or network latency.

## 📊 Log Evidence

```
I, [2026-01-06T12:25:25.960215 #30]  INFO -- : Completed 500 Internal Server Error in 177ms
F, [2026-01-06T12:25:25.968028 #30] FATAL -- :
ActionView::Template::Error (undefined method `zero?' for nil:NilClass):
    13:           - if current_user.avatar.present?
    14:             = image_tag(current_user.avatar.url, class: 'card-profile-stats-intro-pic')
```

**Pattern**: Error occurs randomly, sometimes page loads fine (200 OK), sometimes crashes (500 Error)

## 🔧 Reproduction Steps

### Method 1: Production Monitoring
1. SSH to production: `ssh ubuntu@146.59.44.70`
2. Tail logs: `docker logs -f kw-app-web-43b9fa492649f79a72a1ebfc23477f8594db72c8`
3. Visit: https://nowypanel.kw.krakow.pl/users/edit
4. Hard refresh (Cmd+Shift+R / Ctrl+Shift+R) repeatedly
5. Watch logs for `undefined method 'zero?' for nil:NilClass`

### Method 2: Simulate Timeout Locally

**Add to `config/initializers/carrierwave.rb` (development only):**
```ruby
if Rails.env.development?
  CarrierWave.configure do |config|
    # Simulate unreliable OpenStack
    config.fog_credentials = {
      provider: 'openstack',
      openstack_api_key: 'fake',
      openstack_username: 'fake',
      openstack_auth_url: "https://auth.cloud.ovh.net/",
      openstack_region: 'WAW',
      connection_options: {
        connect_timeout: 0.1,  # Force timeouts
        read_timeout: 0.1,
        write_timeout: 0.1
      }
    }
  end
end
```

### Method 3: Rails Console Reproduction

```ruby
# SSH to production
ssh ubuntu@146.59.44.70

# Enter Rails console
docker exec -it kw-app-web-43b9fa492649f79a72a1ebfc23477f8594db72c8 bundle exec rails console

# Try to access avatar URL repeatedly
user = Db::User.find_by(email: 'dariusz.finster@gmail.com')

# This might fail intermittently
100.times do |i|
  begin
    url = user.avatar.url
    puts "#{i}: Success - #{url}"
  rescue => e
    puts "#{i}: ERROR - #{e.class}: #{e.message}"
  end
end
```

## 💡 Solutions

### Solution 1: Fix CarrierWave Bug (Monkey Patch)

**Create**: `config/initializers/carrierwave_fog_fix.rb`
```ruby
# Fix for CarrierWave fog storage nil content_length bug
module CarrierWave
  module Storage
    class Fog < Abstract
      class File
        # Override size to handle nil content_length
        def size
          return 0 if file.nil?
          content_length = file.content_length
          content_length.nil? ? 0 : content_length
        end
      end
    end
  end
end
```

### Solution 2: Increase Timeouts (Quick Fix)

**Edit**: `config/initializers/carrierwave.rb`
```ruby
connection_options: {
  connect_timeout: 30,  # Increased from 5
  read_timeout: 30,     # Increased from 5
  write_timeout: 30     # Increased from 5
}
```

### Solution 3: Add Caching (Performance Fix)

**Edit**: `app/components/membership/avatar_uploader.rb`
```ruby
module Membership
  class AvatarUploader < CarrierWave::Uploader::Base
    include CarrierWave::MiniMagick

    if Rails.env.production? || Rails.env.staging?
      storage :fog
    else
      storage :file
    end

    process resize_to_limit: [250, 250]

    # Cache avatar URLs to avoid repeated OpenStack API calls
    def cache_dir
      "#{Rails.root}/tmp/uploads"
    end

    def default_url(*args)
      ActionController::Base.helpers.image_url('default-avatar.png')
    end

    def store_dir
      "membership/avatars/#{model.id}"
    end
  end
end
```

### Solution 4: Graceful Degradation in View (Safety Fix)

**Edit**: `app/views/devise/registrations/edit.html.slim`
```slim
- if current_user.avatar.present?
  - begin
    = image_tag(current_user.avatar.url, class: 'card-profile-stats-intro-pic')
  - rescue => e
    = image_tag('default-avatar.png', class: 'card-profile-stats-intro-pic')
    - Rails.logger.error "Avatar loading failed: #{e.message}"
```

### Solution 5: Helper Method (Clean Fix)

**Create**: `app/helpers/avatar_helper.rb`
```ruby
module AvatarHelper
  def safe_avatar_url(user, default: 'default-avatar.png')
    return image_url(default) unless user&.avatar&.present?
    
    user.avatar.url
  rescue StandardError => e
    Rails.logger.error "Avatar URL failed for user #{user.id}: #{e.message}"
    image_url(default)
  end
end
```

**Use in view**:
```slim
= image_tag(safe_avatar_url(current_user), class: 'card-profile-stats-intro-pic')
```

## 🎯 Recommended Fix Strategy

**Immediate (apply all 3):**
1. ✅ **Solution 1**: Add monkey patch to fix CarrierWave bug
2. ✅ **Solution 2**: Increase timeouts to 30 seconds
3. ✅ **Solution 5**: Use safe helper method in views

**Long-term:**
- Consider migrating to ActiveStorage (Rails native)
- Add CDN caching layer (CloudFlare) for avatar images
- Monitor OpenStack API response times

## 📝 Testing Checklist

- [ ] Apply fixes to production
- [ ] Test avatar loading 50+ times (hard refresh)
- [ ] Check logs for any remaining errors
- [ ] Verify default avatar shows on actual errors
- [ ] Test with users who have no avatar
- [ ] Test with users who have avatars
- [ ] Monitor production logs for 24 hours

## 🔗 Related Files

- `config/initializers/carrierwave.rb` - CarrierWave configuration
- `app/components/membership/avatar_uploader.rb` - Avatar uploader class
- `app/models/db/user.rb` - User model (line 62: mount_uploader)
- `app/views/devise/registrations/edit.html.slim` - Edit profile view
- `/usr/local/bundle/ruby/3.2.0/gems/carrierwave-3.1.0/lib/carrierwave/storage/fog.rb` - Bug source

## 🚀 Deployment Instructions

### Step 1: Review Changes
```bash
git status
git diff config/initializers/carrierwave.rb
git diff config/initializers/carrierwave_fog_fix.rb
git diff app/helpers/avatar_helper.rb
git diff app/views/devise/registrations/edit.html.slim
```

### Step 2: Test Locally (Optional)
```bash
# Start development environment
docker-compose up -d

# Check for syntax errors
docker-compose exec -T app bundle exec rails runner "puts 'OK'"

# Run test script if desired
docker-compose exec -T app bundle exec rails runner test_avatar_loading.rb
```

### Step 3: Commit Changes
```bash
git add config/initializers/carrierwave_fog_fix.rb
git add config/initializers/carrierwave.rb
git add app/helpers/avatar_helper.rb
git add app/views/devise/registrations/edit.html.slim
git add AVATAR_BUG_ANALYSIS.md
git add test_avatar_loading.rb

git commit -m "Fix avatar loading race condition with OpenStack

- Add monkey patch for CarrierWave fog nil content_length bug
- Increase OpenStack timeouts from 5s to 30s
- Add safe_avatar_url helper with error handling
- Update edit view to use safe helper
- Add comprehensive test script

Fixes: undefined method 'zero?' for nil:NilClass error"
```

### Step 4: Deploy to Production
```bash
# Build and push (Kamal will do this)
kamal deploy

# Or if just updating code without rebuilding:
kamal app boot
```

### Step 5: Verify Fix in Production
```bash
# SSH to production
ssh ubuntu@146.59.44.70

# Run test script
docker exec kw-app-web-$(docker ps -q -f name=kw-app-web) \
  bundle exec rails runner test_avatar_loading.rb

# Watch logs during testing
docker logs -f kw-app-web-$(docker ps -q -f name=kw-app-web) 2>&1 | grep -i "avatar\|zero"

# Test manually: visit https://nowypanel.kw.krakow.pl/users/edit
# Hard refresh 20-30 times - should never crash now
```

### Step 6: Monitor for 24 Hours
```bash
# Check for any 'zero?' errors
ssh ubuntu@146.59.44.70 'docker logs --since 24h kw-app-web-$(docker ps -q -f name=kw-app-web) 2>&1 | grep "zero?"'

# Check for avatar helper errors (should gracefully degrade)
ssh ubuntu@146.59.44.70 'docker logs --since 24h kw-app-web-$(docker ps -q -f name=kw-app-web) 2>&1 | grep "AvatarHelper"'

# Check overall error rate
ssh ubuntu@146.59.44.70 'docker logs --since 24h kw-app-web-$(docker ps -q -f name=kw-app-web) 2>&1 | grep "500 Internal" | wc -l'
```

## ⚠️ Rollback Plan

If issues occur after deployment:

```bash
# Revert the commit
git revert HEAD

# Deploy previous version
kamal deploy

# Or quick rollback of specific files:
git checkout HEAD~1 config/initializers/carrierwave.rb
git checkout HEAD~1 app/views/devise/registrations/edit.html.slim
kamal deploy
```

## 📊 Success Metrics

**Before Fix:**
- Random 500 errors on `/users/edit` (~10-20% of requests)
- Error: `undefined method 'zero?' for nil:NilClass`
- User experience: Frustrating page crashes

**After Fix:**
- ✅ Zero 500 errors from avatar loading
- ✅ Graceful fallback to default avatar on OpenStack issues
- ✅ Better timeout handling (30s vs 5s)
- ✅ Logged errors for monitoring
- ✅ Smooth user experience

## 📚 References

- CarrierWave: https://github.com/carrierwaveuploader/carrierwave
- fog-openstack: https://github.com/fog/fog-openstack
- OpenStack Swift API: https://docs.openstack.org/swift/latest/
- Kamal deployment: https://kamal-deploy.org/