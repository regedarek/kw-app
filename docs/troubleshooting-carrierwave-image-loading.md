# Troubleshooting: CarrierWave Intermittent Image Loading (Develop Branch)

## Problem Description

**Symptom**: On `develop` branch, pages with multiple photos (e.g., OLX sale announcements) display images randomly - sometimes 1 image, sometimes 3 images, varying on hard refresh.

**Critical Info**: ✅ **Master branch works fine** - this is a regression introduced in `develop`

**Affected Page**: `app/components/olx/sale_announcements/show.html.slim`

## Root Cause: Database vs File-based MIME Detection

### Code Changes Between Master and Develop

**Master (Working):**
```slim
# app/components/storage/shared/_files.html.slim
- attachments.select{|file| MimeMagic.by_path(file.path)&.image? }.each_with_index do |photo, i|
```
- Reads MIME type from **file path** on OpenStack
- Synchronous check per image
- Always works but makes OpenStack API calls

**Develop (Broken):**
```slim
# app/components/storage/shared/_files.html.slim
- attachments.select { |file| file.model.image? }.each_with_index do |photo, i|
```
- Reads `content_type` from **database column**
- Fast, no OpenStack calls
- **But fails if `content_type` is NULL or incorrect**

### Why It's Intermittent

1. **Old photos** uploaded before `ApplicationUploader` changes → `content_type` is NULL
2. **New photos** uploaded with `ApplicationUploader` → `content_type` is saved
3. Depending on which photos are on the page, some show, some don't

### The ApplicationUploader Change

```ruby
# app/uploaders/application_uploader.rb (NEW in develop)
class ApplicationUploader < CarrierWave::Uploader::Base
  after :store, :save_content_type_to_model
  
  def save_content_type_to_model(file)
    return unless model.respond_to?(:content_type=)
    return if model.content_type.present? # Skip if already set
    
    # Detect and save MIME type to database
    mime = MimeMagic.by_path(file.path)
    model.content_type = mime.type if mime
    model.save if model.persisted?
  end
end
```

**Intent**: Save `content_type` once at upload, avoid repeated OpenStack calls during rendering

**Problem**: Old photos uploaded before this change have NULL `content_type`

## Verification Steps

### Step 1: Check Database Content Types

```bash
docker-compose exec app bundle exec rails console
```

```ruby
# Check sale announcement photos
sa = Olx::SaleAnnouncementRecord.find(ANNOUNCEMENT_ID)

sa.photos.each_with_index do |photo, i|
  puts "Photo #{i}:"
  puts "  ID: #{photo.id}"
  puts "  content_type: #{photo.content_type.inspect}"
  puts "  file path: #{photo.file.path}"
  puts "  image?: #{photo.image?}"
  puts "  MimeMagic: #{MimeMagic.by_path(photo.file.path)&.type}"
  puts ""
end
```

**Expected Output**:
- Old photos: `content_type: nil` → `image?` returns **false** → not displayed
- New photos: `content_type: "image/jpeg"` → `image?` returns **true** → displayed

### Step 2: Count NULL Content Types

```ruby
# How many photos have NULL content_type?
null_count = Storage::UploadRecord.where(content_type: nil).count
total_count = Storage::UploadRecord.count

puts "Photos with NULL content_type: #{null_count} / #{total_count}"

# Which sale announcements are affected?
affected_announcements = Olx::SaleAnnouncementRecord
  .joins(:photos)
  .where(photos: { content_type: nil })
  .distinct

puts "Affected sale announcements: #{affected_announcements.count}"
```

### Step 3: Test Image Detection Method

```ruby
# Compare methods
photo = Storage::UploadRecord.find(PHOTO_ID)

puts "Database method (develop): #{photo.image?}"
puts "File method (master): #{MimeMagic.by_path(photo.file.path)&.image?}"
```

## Solutions

### Solution 1: Backfill Content Types (Recommended)

Run migration to populate `content_type` for existing photos:

```ruby
# lib/tasks/backfill_content_types.rake
namespace :storage do
  desc "Backfill content_type for existing uploads"
  task backfill_content_types: :environment do
    total = Storage::UploadRecord.where(content_type: nil).count
    puts "Found #{total} uploads without content_type"
    
    fixed = 0
    failed = 0
    
    Storage::UploadRecord.where(content_type: nil).find_each do |upload|
      begin
        # Try to detect from file path
        mime = MimeMagic.by_path(upload.file.path)
        
        if mime
          upload.update_column(:content_type, mime.type)
          fixed += 1
          puts "✓ Upload #{upload.id}: #{mime.type}"
        else
          # Fallback to extension
          extension = File.extname(upload.file.path).downcase.delete('.')
          fallback = case extension
            when 'jpg', 'jpeg' then 'image/jpeg'
            when 'png' then 'image/png'
            when 'gif' then 'image/gif'
            when 'webp' then 'image/webp'
            when 'pdf' then 'application/pdf'
            else nil
          end
          
          if fallback
            upload.update_column(:content_type, fallback)
            fixed += 1
            puts "✓ Upload #{upload.id}: #{fallback} (fallback)"
          else
            failed += 1
            puts "✗ Upload #{upload.id}: Could not detect"
          end
        end
      rescue => e
        failed += 1
        puts "✗ Upload #{upload.id}: #{e.message}"
      end
    end
    
    puts ""
    puts "Summary:"
    puts "  Fixed: #{fixed}"
    puts "  Failed: #{failed}"
    puts "  Total: #{total}"
  end
end
```

**Run it:**
```bash
# Development
docker-compose exec app bundle exec rails storage:backfill_content_types

# Production
ssh ubuntu@146.59.44.70
kamal app exec "bundle exec rails storage:backfill_content_types"
```

### Solution 2: Add Fallback in View (Quick Fix)

Modify view to fall back to MimeMagic if `content_type` is missing:

```slim
# app/components/storage/shared/_files.html.slim
- # Image attachments with fallback
- attachments.select { |file| 
    file.model.content_type.present? ? file.model.image? : MimeMagic.by_path(file.path)&.image?
  }.each_with_index do |photo, i|
  - unless photo.blank? || photo.medium.blank?
    = image_tag photo.medium.url, class: 'thumbnail', data: { toggle: "photo-#{i}" }
```

**Pros**: Works immediately, no database changes
**Cons**: Still makes OpenStack API calls for old photos

### Solution 3: Improve image? Method with Fallback

```ruby
# app/components/storage/upload_record.rb
module Storage
  class UploadRecord < ActiveRecord::Base
    # ... existing code ...
    
    def image?
      # Use cached content_type if available
      return content_type.start_with?('image') if content_type.present?
      
      # Fallback to file-based detection for old records
      mime = MimeMagic.by_path(file.path)
      mime&.image? || false
    rescue => e
      Rails.logger.error "[Storage::UploadRecord] image? check failed for #{id}: #{e.message}"
      false
    end
  end
end
```

**Pros**: Transparent fix, works for old and new photos
**Cons**: Still makes OpenStack calls for old photos (but better than broken images)

### Solution 4: Revert to Master Approach (Safest)

If you need immediate fix while investigating:

```bash
# Revert just the view change
git checkout master -- app/components/storage/shared/_files.html.slim
```

**Pros**: Immediate fix, proven to work
**Cons**: Loses the performance optimization

## Recommended Implementation

### Phase 1: Immediate Fix (5 minutes)
1. ✅ Apply **Solution 3** (improve `image?` method with fallback)
2. ✅ Deploy to production
3. ✅ Verify images display consistently

### Phase 2: Data Migration (30 minutes)
4. ✅ Run **Solution 1** (backfill content types) in development
5. ✅ Verify all photos have `content_type`
6. ✅ Deploy rake task to production
7. ✅ Run backfill task in production

### Phase 3: Cleanup (optional)
8. ⚠️ Remove fallback from `image?` method once all records have `content_type`
9. ⚠️ Add database constraint: `ALTER TABLE storage_uploads ADD CONSTRAINT content_type_required CHECK (content_type IS NOT NULL)`

## Environment Differences (Docker/Gems)

**Other changes between master and develop:**

### Ruby Version
- Master: Ruby 2.6.6
- Develop: Ruby 3.2.2

### CarrierWave Version
- Master: `carrierwave 1.3.2`
- Develop: `carrierwave 3.1.2` (major version upgrade!)

### fog-openstack Version
- Master: `fog-openstack 1.0.11`
- Develop: `fog-openstack 1.1.5`

### Docker Setup
- Master: Alpine-based, gems in `/kw-app-gems`
- Develop: Debian slim, gems in volume `kw-app-bundle`

**Note**: These changes are unlikely to cause intermittent loading, but CarrierWave 3.x may have behavior changes.

## Testing After Fix

```bash
# 1. Backfill content types
docker-compose exec app bundle exec rails storage:backfill_content_types

# 2. Verify all NULL are gone
docker-compose exec app bundle exec rails runner "
  puts 'NULL content_types: ' + Storage::UploadRecord.where(content_type: nil).count.to_s
"

# 3. Test specific announcement
docker-compose exec app bundle exec rails runner "
  sa = Olx::SaleAnnouncementRecord.find(YOUR_ID)
  puts 'Total photos: ' + sa.photos.count.to_s
  puts 'Images: ' + sa.photos.select(&:image?).count.to_s
"

# 4. Load page multiple times, verify consistent display
```

## Prevention

### For Future Uploads

The `ApplicationUploader` already handles this:

```ruby
after :store, :save_content_type_to_model
```

All new uploads will have `content_type` saved automatically.

### Add Validation

```ruby
# app/components/storage/upload_record.rb
validates :content_type, presence: true
```

### Add Database Migration

```ruby
class MakeContentTypeNotNull < ActiveRecord::Migration[7.1]
  def up
    # First backfill
    execute <<-SQL
      UPDATE storage_uploads 
      SET content_type = 'application/octet-stream' 
      WHERE content_type IS NULL
    SQL
    
    # Then add constraint
    change_column_null :storage_uploads, :content_type, false
  end
  
  def down
    change_column_null :storage_uploads, :content_type, true
  end
end
```

## Summary

**Root Cause**: View changed from file-based MIME detection to database-based detection, but old photos have NULL `content_type`

**Why Intermittent**: Depends on which photos are on the page (old vs new uploads)

**Fix**: Backfill `content_type` for existing photos + add fallback in `image?` method

**Prevention**: Already implemented via `ApplicationUploader`, just need to handle legacy data