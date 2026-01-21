# CarrierWave to Active Storage Migration Plan

## Executive Summary

Migrate from CarrierWave to Active Storage using `activestorage-openstack` gem for OVH OpenStack storage. This plan provides a complete strategy to replace all CarrierWave uploaders with Active Storage while maintaining zero downtime.

## Current State Analysis

### CarrierWave Uploaders Inventory

**Base Uploaders:**
- `ApplicationUploader` - Base class with content_type detection and OpenStack storage
- `AttachmentUploader` - Image processing with thumb version (180x180)
- `CsvUploader` - CSV-only, local storage

**Specialized Uploaders (22 total):**

| Uploader | Usage | Features | Models Using |
|----------|-------|----------|--------------|
| `AttachmentUploader` | General attachments | Thumb 180x180, auto-orient | MountainRoute, Library, Management, ProfileList |
| `Storage::FileUploader` | Polymorphic uploads | Large/Medium/Thumb variants | UploadRecord |
| `Membership::AvatarUploader` | User avatars | 250x250 resize, default fallback | User |
| `PhotoCompetition::FileUploader` | Photo submissions | Thumb 100x100, Preview 1024x1024 | PhotoRequest |
| `Training::Activities::GpsTrackUploader` | GPS tracks | Basic storage | MountainRoute |
| `Events::Competitions::BanerUploader` | Event banners | ? | CompetitionRecord |
| `Training::Supplementary::BanerUploader` | Course banners | ? | CourseRecord |
| `Settlement::AttachmentUploader` | Contract docs | ? | ContractRecord |
| `Settlement::ContractorLogoUploader` | Contractor logos | ? | ContractorRecord |
| `Management::AttachmentUploader` | Multiple docs | ? | ProjectRecord, SnwApplyRecord, VotingCaseRecord, SponsorshipRequest |
| `Library::AttachmentUploader` | Library files | ? | ItemRecord |
| `Management::News::AttachmentUploader` | News attachments | ? | InformationRecord |
| `Reservations::PhotoUploader` | Reservation photos | ? | Reservation |
| `UserManagement::PhotoUploader` | Profile photos | ? | Profile |
| `UserManagement::AttachmentUploader` | Profile docs | ? | ProfileListRecord |
| `YearlyPrize::AttachmentUploader` | Prize docs | ? | YearlyPrizeRequest |
| `Scrappers::*` | External data | Images, PDFs | MeteoblueRecord, ShmuRecord, ToprRecord |

**Usage Patterns:**
- `mount_uploader` - Single file (e.g., avatar, logo, banner)
- `mount_uploaders` - Multiple files (e.g., attachments, photos)
- Most use `serialize :attachments, JSON` for arrays

### Key Features to Preserve

1. **Image Processing**: Auto-orient, resize variants (thumb, medium, large)
2. **Content Type Detection**: Automatic MIME type detection and storage
3. **File Size Tracking**: Store file size in model
4. **Custom Storage Paths**: Organized by model/id
5. **Extension Whitelisting**: CSV, images only for certain uploaders
6. **Default Images**: Fallback for missing avatars

## Migration Strategy: Generic Active Storage Pattern

### Phase 1: Setup (Day 1)

#### 1.1 Install Active Storage

```bash
docker-compose exec -T app bin/rails active_storage:install
docker-compose exec -T app bin/rails db:migrate
```

#### 1.2 Add Required Gems

```ruby
# Gemfile
gem 'activestorage-openstack'
gem 'active_storage_validations'  # For validations
gem 'image_processing', '~> 1.2'  # For variants
```

```bash
docker-compose restart app
```

#### 1.3 Configure OpenStack Storage

```yaml
# config/storage.yml
openstack:
  service: OpenStack
  container: <%= "kw-app-cloud-#{Rails.env}" %>
  credentials:
    openstack_auth_url: "https://auth.cloud.ovh.net/"
    openstack_username: <%= Rails.application.credentials.dig(:openstack, :username) %>
    openstack_api_key: <%= Rails.application.credentials.dig(:openstack, :api_key) %>
    openstack_region: "WAW"
    openstack_temp_url_key: <%= Rails.application.credentials.dig(:openstack, :temp_url_key) %>
  connection_options:
    chunk_size: 1.megabyte
    connect_timeout: 60
    read_timeout: 60
    write_timeout: 60

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>
```

#### 1.4 Update Environment Configs

```ruby
# config/environments/development.rb
config.active_storage.service = :openstack

# config/environments/production.rb
config.active_storage.service = :openstack

# config/environments/test.rb
config.active_storage.service = :test
```

#### 1.5 Add Performance Monitoring

```ruby
# config/initializers/active_storage_monitoring.rb
ActiveSupport::Notifications.subscribe "service_upload.active_storage" do |name, start, finish, id, payload|
  duration = ((finish - start) * 1000).round(2)
  Rails.logger.info "[ActiveStorage] Upload: #{payload[:key]} (#{duration}ms)"
  
  if duration > 5000
    Rails.logger.warn "[ActiveStorage] Slow upload: #{payload[:key]} - #{duration}ms"
  end
end

ActiveSupport::Notifications.subscribe "service_download.active_storage" do |name, start, finish, id, payload|
  duration = ((finish - start) * 1000).round(2)
  
  if duration > 5000
    Rails.logger.warn "[ActiveStorage] Slow download: #{payload[:key]} - #{duration}ms"
  end
end
```

### Phase 2: Generic Conversion Patterns (Day 2-3)

#### Pattern 1: Single Image with Variants

**CarrierWave:**
```ruby
class User < ApplicationRecord
  mount_uploader :avatar, Membership::AvatarUploader
end
```

**Active Storage:**
```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [250, 250]
  end
  
  validates :avatar,
    content_type: ['image/png', 'image/jpeg', 'image/gif', 'image/webp'],
    size: { less_than: 5.megabytes }
end
```

#### Pattern 2: Multiple Files (Attachments)

**CarrierWave:**
```ruby
class MountainRoute < ApplicationRecord
  mount_uploaders :attachments, AttachmentUploader
  serialize :attachments, JSON
end
```

**Active Storage:**
```ruby
class MountainRoute < ApplicationRecord
  has_many_attached :attachments do |attachable|
    attachable.variant :thumb, resize_to_fill: [180, 180]
  end
  
  validates :attachments,
    content_type: ['image/png', 'image/jpeg', 'image/gif', 'application/pdf'],
    size: { less_than: 10.megabytes },
    limit: { max: 20 }
end
```

#### Pattern 3: Polymorphic Storage (Storage::UploadRecord)

**CarrierWave:**
```ruby
class Storage::UploadRecord < ApplicationRecord
  belongs_to :uploadable, polymorphic: true
  mount_uploader :file, Storage::FileUploader
end
```

**Active Storage (Replace entire model):**
```ruby
# Active Storage handles this natively with has_one_attached/has_many_attached
# No need for separate Storage::UploadRecord model

# Usage in other models:
class Event < ApplicationRecord
  has_many_attached :documents
end
```

#### Pattern 4: Photo Competition (Custom Filenames)

**CarrierWave:**
```ruby
class PhotoCompetition::FileUploader < ApplicationUploader
  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end
end
```

**Active Storage:**
```ruby
class PhotoCompetition::RequestRecord < ApplicationRecord
  has_one_attached :file do |attachable|
    attachable.variant :thumb, resize_to_fill: [100, 100]
    attachable.variant :preview, resize_to_fit: [1024, 1024]
  end
  
  before_create :set_secure_filename
  
  private
  
  def set_secure_filename
    if file.attached?
      blob = file.blob
      extension = File.extname(blob.filename.to_s)
      new_filename = "#{SecureRandom.uuid}#{extension}"
      blob.update(filename: new_filename)
    end
  end
end
```

### Phase 3: Model-by-Model Migration (Day 4-8)

#### Migration Priority Order

**Week 1 - Low Risk:**
1. `Db::User` (avatar) - Most visible, test thoroughly
2. `Db::Profile` (photo, course_cert)
3. `Settlement::ContractorRecord` (logo)
4. `Training::Supplementary::CourseRecord` (baner)
5. `Events::Db::CompetitionRecord` (baner)

**Week 2 - Medium Risk:**
6. `Activities::MountainRouteRecord` (attachments, gps_tracks)
7. `Library::ItemRecord` (attachments)
8. `Management::ProjectRecord` (attachments)
9. `Marketing::DiscountRecord` (attachments, image)
10. `Db::Reservation` (photos)

**Week 3 - Higher Risk:**
11. `Settlement::ContractRecord` (attachments)
12. `PhotoCompetition::RequestRecord` (file)
13. `Storage::UploadRecord` (polymorphic - needs refactor)
14. All `Management::*` models with attachments

**Week 4 - Scrapers & Cleanup:**
15. `Scrappers::*` (external data imports)
16. Remaining models
17. Remove CarrierWave entirely

#### Generic Migration Template

For each model, follow this pattern:

**Step 1: Add Active Storage alongside CarrierWave**
```ruby
class ModelName < ApplicationRecord
  # OLD - Keep temporarily
  mount_uploader :old_field, OldUploader
  
  # NEW - Add alongside
  has_one_attached :new_field do |attachable|
    attachable.variant :thumb, resize_to_fill: [180, 180]
    # Define other variants as needed
  end
  
  validates :new_field,
    content_type: ['image/png', 'image/jpeg'],
    size: { less_than: 5.megabytes }
end
```

**Step 2: Update Forms**
```erb
<%= form_with model: @record do |f| %>
  <%= f.file_field :new_field, accept: "image/*" %>
  
  <% if @record.new_field.attached? %>
    <%= image_tag @record.new_field.variant(:thumb) %>
  <% elsif @record.old_field.present? %>
    <%= image_tag @record.old_field.url(:thumb) %>
  <% end %>
<% end %>
```

**Step 3: Update Controllers**
```ruby
def model_params
  params.require(:model_name).permit(:name, :new_field)
end
```

**Step 4: Update Views**
```erb
<% if @record.new_field.attached? %>
  <%= image_tag @record.new_field.variant(:thumb) %>
<% elsif @record.old_field.present? %>
  <%= image_tag @record.old_field.url(:thumb) %>
<% else %>
  <%= image_tag "default.png" %>
<% end %>
```

**Step 5: Write Migration Task (Optional)**

Only if you want to migrate existing files (not required):

```ruby
# lib/tasks/migrate_files.rake
namespace :storage do
  desc "Migrate specific model to Active Storage"
  task :migrate_model, [:model_class, :old_field, :new_field] => :environment do |t, args|
    model_class = args[:model_class].constantize
    old_field = args[:old_field].to_sym
    new_field = args[:new_field].to_sym
    
    model_class.find_each do |record|
      next unless record.send(old_field).present?
      next if record.send(new_field).attached?
      
      begin
        file = record.send(old_field)
        
        record.send(new_field).attach(
          io: StringIO.new(file.read),
          filename: file.file.filename,
          content_type: file.content_type
        )
        
        puts "✓ Migrated #{model_class.name}##{record.id}"
      rescue => e
        puts "✗ Failed #{model_class.name}##{record.id}: #{e.message}"
      end
    end
  end
end
```

**Step 6: Test Thoroughly**
```ruby
# spec/models/model_name_spec.rb
RSpec.describe ModelName do
  describe "new_field attachment" do
    let(:record) { create(:model_name) }
    
    it "attaches file" do
      record.new_field.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test.jpg")),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )
      
      expect(record.new_field).to be_attached
    end
    
    it "generates variants" do
      record.new_field.attach(
        io: File.open(Rails.root.join("spec/fixtures/files/test.jpg")),
        filename: "test.jpg",
        content_type: "image/jpeg"
      )
      
      expect(record.new_field.variant(:thumb)).to be_present
    end
    
    it "validates content type" do
      record.new_field.attach(
        io: StringIO.new("not an image"),
        filename: "fake.exe",
        content_type: "application/x-msdownload"
      )
      
      expect(record).not_to be_valid
    end
  end
end
```

**Step 7: Deploy & Monitor**
```bash
# Deploy changes
kamal deploy

# Monitor logs
kamal app logs -f | grep ActiveStorage

# Verify uploads work
kamal app exec "bundle exec rails runner 'puts ActiveStorage::Blob.count'"
```

### Phase 4: CarrierWave Removal (Day 9-10)

Once ALL models are migrated and verified:

#### 4.1 Remove CarrierWave Code

```ruby
# Remove from each model:
# - mount_uploader lines
# - serialize :field, JSON lines (for arrays)

# Example:
class MountainRoute < ApplicationRecord
  # DELETE THESE:
  # mount_uploaders :attachments, AttachmentUploader
  # serialize :attachments, JSON
  
  # KEEP THIS:
  has_many_attached :attachments
end
```

#### 4.2 Delete Uploader Files

```bash
rm -rf app/uploaders/
rm -rf app/components/*/attachment_uploader.rb
rm -rf app/components/*/*/*uploader.rb
```

#### 4.3 Remove CarrierWave Gems

```ruby
# Gemfile - REMOVE:
# gem 'carrierwave'
# gem 'carrierwave-i18n'
# gem 'mini_magick'  # Only if not used elsewhere
# gem 'fog-openstack'
```

#### 4.4 Remove Initializers

```bash
rm config/initializers/carrierwave.rb
rm config/initializers/carrierwave_fog_fix.rb
```

#### 4.5 Remove Database Columns

```ruby
# db/migrate/YYYYMMDDHHMMSS_remove_carrierwave_columns.rb
class RemoveCarrierwaveColumns < ActiveRecord::Migration[7.1]
  def change
    # Single uploaders
    remove_column :users, :avatar, :string
    remove_column :profiles, :photo, :string
    remove_column :profiles, :course_cert, :string
    remove_column :contractors, :logo, :string
    remove_column :courses, :baner, :string
    remove_column :competitions, :baner, :string
    
    # Multiple uploaders (stored as JSON)
    remove_column :mountain_routes, :attachments, :text
    remove_column :mountain_routes, :gps_tracks, :text
    remove_column :library_items, :attachments, :text
    remove_column :projects, :attachments, :text
    remove_column :contracts, :attachments, :text
    remove_column :reservations, :photos, :text
    remove_column :profile_lists, :attachments, :text
    remove_column :yearly_prize_requests, :attachments, :text
    remove_column :management_informations, :attachments, :text
    remove_column :snw_applies, :attachments, :text
    remove_column :management_cases, :attachments, :text
    remove_column :marketing_discounts, :attachments, :text
    remove_column :marketing_discounts, :image, :string
    remove_column :marketing_sponsorship_requests, :attachments, :text
    
    # Photo competition
    remove_column :photo_requests, :file, :string
    
    # Scrapers
    remove_column :meteoblue_records, :meteogram, :string
    remove_column :shmu_diagrams, :image, :string
    remove_column :topr_records, :topr_pdf, :string
    remove_column :topr_records, :topr_degree, :string
    
    # Storage (if refactored to native Active Storage)
    # Consider removing entire storage_uploads table if no longer needed
  end
end
```

```bash
docker-compose exec -T app bin/rails db:migrate
```

## Variant Mapping Reference

Common CarrierWave versions → Active Storage variants:

| CarrierWave | Active Storage |
|-------------|----------------|
| `resize_to_fill: [180, 180]` | `resize_to_fill: [180, 180]` |
| `resize_to_limit: [250, 250]` | `resize_to_limit: [250, 250]` |
| `resize_to_fit: [1024, 1024]` | `resize_to_fit: [1024, 1024]` |
| `process :auto_orient` | Built-in (automatic) |

## Testing Strategy

### Manual Testing Checklist

For each model:
- [ ] Upload new file
- [ ] View file in show page
- [ ] Edit and replace file
- [ ] Delete file
- [ ] View thumbnail/variant
- [ ] Verify file accessible via URL
- [ ] Check file stored in OpenStack container

### Automated Testing

```ruby
# spec/support/active_storage_helpers.rb
module ActiveStorageHelpers
  def attach_file_to(record, field, filename: "test.jpg", content_type: "image/jpeg")
    record.send(field).attach(
      io: File.open(Rails.root.join("spec/fixtures/files", filename)),
      filename: filename,
      content_type: content_type
    )
  end
end

RSpec.configure do |config|
  config.include ActiveStorageHelpers
end
```

## Rollback Strategy

### If Migration Fails

1. **Keep CarrierWave functional** - Don't remove until fully verified
2. **Revert form changes** - Change `:new_field` back to `:old_field`
3. **Database safe** - Active Storage uses separate tables
4. **No data loss** - Both systems can coexist

### Emergency Rollback Steps

```bash
# 1. Revert code changes
git revert HEAD

# 2. Redeploy
kamal deploy

# 3. Verify CarrierWave still works
kamal app logs -f | grep CarrierWave
```

## Deployment Strategy

### Development Testing (Week 1-2)

```bash
# Install gems
docker-compose restart app

# Run migrations
docker-compose exec -T app bin/rails db:migrate

# Test one model
docker-compose exec app bundle exec rails console
> User.first.avatar.attach(io: File.open("test.jpg"), filename: "test.jpg")
> User.first.avatar.attached?
```

### Staging Deployment (Week 3)

```bash
# Deploy to staging environment
RAILS_ENV=staging kamal deploy

# Run smoke tests
# - Upload files through UI
# - Verify variants generate
# - Check OpenStack storage
```

### Production Deployment (Week 4)

```bash
# Deploy during low-traffic window
kamal deploy

# Monitor logs intensively
kamal app logs -f | grep -E "ActiveStorage|CarrierWave|Upload"

# Check error rates
kamal app exec "bundle exec rails runner 'puts ActiveStorage::Blob.count'"
```

## Performance Considerations

### OpenStack Connection Tuning

Already configured in storage.yml:
- `connect_timeout: 60` - Prevent hanging
- `read_timeout: 60` - Large file downloads
- `write_timeout: 60` - Large file uploads
- `chunk_size: 1.megabyte` - Stream large files

### Eager Loading

```ruby
# Prevent N+1 queries
User.with_attached_avatar.limit(10)

# Multiple attachments
MountainRoute.with_attached_attachments.with_attached_gps_tracks
```

### Caching Variants

```ruby
# In controller
@users = User.with_attached_avatar.limit(10)

# Preload variants
@users.each do |user|
  user.avatar.variant(:thumb).processed if user.avatar.attached?
end
```

## Monitoring & Alerts

### Key Metrics to Track

- Upload success rate
- Upload duration (p50, p95, p99)
- Download duration
- OpenStack connection errors
- Variant generation time

### Log Patterns to Monitor

```bash
# Successful uploads
kamal app logs | grep "ActiveStorage.*Upload.*ms"

# Slow operations (>5s)
kamal app logs | grep "Slow upload\|Slow download"

# Errors
kamal app logs | grep "ERROR.*ActiveStorage"
```

## Timeline Summary

- **Week 1**: Setup + Low-risk models (Users, Profiles)
- **Week 2**: Medium-risk models (Routes, Library, Management)
- **Week 3**: High-risk models (Contracts, Storage refactor)
- **Week 4**: Scrapers, Testing, CarrierWave removal

**Total**: ~4 weeks for complete migration

## Checklist

### Phase 1: Setup
- [ ] Install Active Storage
- [ ] Add gems (activestorage-openstack, active_storage_validations, image_processing)
- [ ] Configure storage.yml
- [ ] Update environment configs
- [ ] Add monitoring initializer
- [ ] Test in development

### Phase 2-3: Migration
- [ ] Migrate Db::User
- [ ] Migrate Db::Profile
- [ ] Migrate Settlement::ContractorRecord
- [ ] Migrate Training/Events (baners)
- [ ] Migrate Activities::MountainRouteRecord
- [ ] Migrate Library::ItemRecord
- [ ] Migrate Management models
- [ ] Migrate Marketing models
- [ ] Migrate Settlement::ContractRecord
- [ ] Migrate PhotoCompetition
- [ ] Refactor Storage::UploadRecord
- [ ] Migrate Reservations
- [ ] Migrate Scrapers

### Phase 4: Cleanup
- [ ] Verify ALL models migrated
- [ ] Remove mount_uploader from all models
- [ ] Delete uploader files
- [ ] Remove CarrierWave gems
- [ ] Remove initializers
- [ ] Create migration to drop columns
- [ ] Deploy and verify production
- [ ] Monitor for 1 week
- [ ] Close migration project