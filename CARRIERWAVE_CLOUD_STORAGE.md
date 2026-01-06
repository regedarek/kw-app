# CarrierWave Cloud Storage Configuration

## Overview

This application uses CarrierWave for file uploads with support for:
- **Local file storage** (development default)
- **OpenStack Object Storage** (production, staging, and optional development)

## Architecture

### Base Uploader
All uploaders inherit from `ApplicationUploader` which centralizes storage configuration:

```ruby
# app/uploaders/application_uploader.rb
class ApplicationUploader < CarrierWave::Uploader::Base
  if Rails.env.production? || Rails.env.staging? || ENV['USE_CLOUD_STORAGE'] == 'true'
    storage :fog
  else
    storage :file
  end
end
```

### Storage Decision Logic
- **Production**: Always uses OpenStack (fog)
- **Staging**: Always uses OpenStack (fog)
- **Development**: Uses local file storage by default, switches to OpenStack when `USE_CLOUD_STORAGE=true`

## Dependencies

```ruby
# Gemfile
gem 'carrierwave', '~> 3.1.2'
gem 'fog-openstack', '~> 1.1.5', require: "fog/openstack"
```

## OpenStack Configuration

### Credentials (config/secrets.yml)
```yaml
development:
  openstack_api_key: "YOUR_OPENSTACK_PASSWORD"
  openstack_username: "YOUR_OPENSTACK_USERNAME"
  openstack_asset_host: "https://storage.waw.cloud.ovh.net"

staging:
  openstack_api_key: <%= ENV["OPENSTACK_API_KEY"] %>
  openstack_username: <%= ENV["OPENSTACK_USERNAME"] %>
  openstack_asset_host: "https://storage.waw.cloud.ovh.net"

production:
  openstack_api_key: <%= ENV["OPENSTACK_API_KEY"] %>
  openstack_username: <%= ENV["OPENSTACK_USERNAME"] %>
  openstack_asset_host: "https://storage.waw.cloud.ovh.net"
```

### Container Names
- **Production**: `kw-app-cloud-production`
- **Staging**: `kw-app-cloud-staging`
- **Development (when enabled)**: `kw-app-cloud-staging`

### Endpoints
- **Auth URL**: `https://auth.cloud.ovh.net/`
- **Region**: `WAW` (Warsaw)
- **Storage URL**: `https://storage.waw.cloud.ovh.net/v1/AUTH_b69bb975c19b4ec482592361f1ef5e29/`

## Testing Cloud Storage in Development

### Step 1: Add Credentials
Edit `config/secrets.yml` and add OpenStack credentials to the `development` section:

```yaml
development:
  openstack_api_key: "YOUR_PASSWORD_HERE"
  openstack_username: "YOUR_USERNAME_HERE"
  openstack_asset_host: "https://storage.waw.cloud.ovh.net"
```

### Step 2: Enable Cloud Storage
Set the environment variable before starting your development server:

```bash
# Enable cloud storage (uses staging container)
export USE_CLOUD_STORAGE=true

# Start development server
docker-compose up
```

Or inline:
```bash
USE_CLOUD_STORAGE=true docker-compose up
```

### Step 3: Verify Configuration
Check logs on startup to confirm cloud storage is active:

```bash
docker-compose logs app | grep "CarrierWave"
```

Expected output:
```
CarrierWave: Using OpenStack fog storage with container: kw-app-cloud-staging
```

### Step 4: Disable Cloud Storage
Simply unset the variable or restart without it:

```bash
unset USE_CLOUD_STORAGE
docker-compose restart app
```

Expected log output:
```
CarrierWave: Using local file storage
```

## Docker Compose Integration

Add to your `docker-compose.yml` to enable cloud storage:

```yaml
services:
  app:
    environment:
      - USE_CLOUD_STORAGE=${USE_CLOUD_STORAGE:-false}
```

Or use `.env` file:
```bash
# .env
USE_CLOUD_STORAGE=true
```

## All Uploaders

The following uploaders inherit from `ApplicationUploader`:

**Core Uploaders:**
- `AttachmentUploader` - Generic file attachments
- `CsvUploader` - CSV imports (file storage only)

**Component Uploaders:**
- `Events::Competitions::BanerUploader` - Competition banners
- `Library::AttachmentUploader` - Library files
- `Management::AttachmentUploader` - Management documents
- `Management::News::AttachmentUploader` - News attachments
- `Membership::AvatarUploader` - Member avatars
- `PhotoCompetition::FileUploader` - Photo competition entries
- `Reservations::PhotoUploader` - Reservation photos
- `Scrappers::ImageUploader` - Scraped images
- `Scrappers::MeteoblueUploader` - Weather data images
- `Scrappers::ToprDegreeUploader` - TOPR degree images
- `Scrappers::ToprPdfUploader` - TOPR PDF files
- `Settlement::AttachmentUploader` - Settlement documents
- `Settlement::ContractorLogoUploader` - Contractor logos
- `Storage::FileUploader` - Generic storage files
- `Training::Activities::GpsTrackUploader` - GPS tracks
- `Training::Supplementary::BanerUploader` - Training banners
- `UserManagement::AttachmentUploader` - User documents
- `UserManagement::PhotoUploader` - User photos
- `YearlyPrize::AttachmentUploader` - Prize documents

## Troubleshooting

### Files Not Uploading to Cloud
1. Check credentials in `config/secrets.yml`
2. Verify `USE_CLOUD_STORAGE=true` is set
3. Check logs: `docker-compose logs app | grep CarrierWave`
4. Verify network connectivity to OpenStack

### Authentication Errors
```ruby
# Test connection in Rails console
docker-compose exec app bundle exec rails console

# Test OpenStack connection
fog = Fog::OpenStack::Storage.new(
  openstack_auth_url: 'https://auth.cloud.ovh.net/',
  openstack_username: Rails.application.secrets.openstack_username,
  openstack_api_key: Rails.application.secrets.openstack_api_key,
  openstack_region: 'WAW'
)
fog.directories.all
```

### Container Not Found
Ensure the container exists in OpenStack:
- **Staging**: `kw-app-cloud-staging`
- **Production**: `kw-app-cloud-production`

### Mixed Storage (some files local, some cloud)
This happens when `USE_CLOUD_STORAGE` is changed after files were uploaded:
- Files uploaded locally remain in `public/uploads/`
- Files uploaded to cloud remain in OpenStack
- Uploader will look in current storage location only

## Best Practices

1. **Never commit credentials** - Use environment variables in production/staging
2. **Test uploads** - Always test file upload/download when switching storage
3. **Backup containers** - Regularly backup OpenStack containers
4. **Monitor storage** - Check OpenStack storage usage and quotas
5. **Development testing** - Use staging container to avoid polluting production data

## Configuration Reference

### CarrierWave Initializer
Location: `config/initializers/carrierwave.rb`

Key settings:
- `fog_provider`: 'fog/openstack'
- `fog_public`: false (files are private)
- `connection_options`: 60s timeouts
- `persistent`: true (connection pooling)

### Environment Variables
- `USE_CLOUD_STORAGE` - Enable cloud storage in development (default: false)
- `OPENSTACK_API_KEY` - OpenStack password (staging/production)
- `OPENSTACK_USERNAME` - OpenStack username (staging/production)