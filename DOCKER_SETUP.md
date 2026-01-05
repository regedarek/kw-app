# Docker Setup Documentation

## Overview
This Rails application runs on Docker with multiple services. It's configured to run alongside other Docker projects (like `traction-main-app`) without port conflicts.

## Services & Port Mappings

### Application Services
- **Rails App**: `localhost:3002` → container `3002`
- **Sidekiq**: Background job processor (no exposed port)
- **PostgreSQL**: `localhost:5433` → container `5432`
- **Redis**: `localhost:6380` → container `6379`
- **Mailcatcher SMTP**: `localhost:1025` → container `1025`
- **Mailcatcher Web UI**: `localhost:1080` → container `1080`

### Port Configuration
Ports were adjusted from defaults to avoid conflicts with `traction-main-app`:
- PostgreSQL: `5432` → `5433` (default was 5432)
- Redis: `6379` → `6380` (default was 6379)

## Volume Configuration

### Named Volumes
- `kw-app-bundle`: Bundle gems stored in `/usr/local/bundle`
- `kw-app-tmp`: Rails temporary files in `/rails/tmp`
- `kw-app-postgres`: PostgreSQL data persistence
- `kw-app-redis-data`: Redis data persistence

### Volume Separation (Important!)
- **Bundle gems** (`/usr/local/bundle`): Contains installed Ruby gems
- **Rails tmp** (`/rails/tmp`): Contains Rails cache, pids, sockets
- **Code mount** (`.:/rails`): Live code for development

This separation ensures:
1. Gems persist between container rebuilds
2. Rails cache doesn't interfere with gems
3. Code changes reflect immediately in containers

## First Time Setup

### 1. Build the containers
```bash
docker-compose build --no-cache
```

### 2. Create the databases
```bash
docker-compose up -d postgres redis mailcatcher
sleep 5
docker-compose exec -T postgres psql -U dev-user -c "CREATE DATABASE kw_app_development;" postgres
docker-compose exec -T postgres psql -U dev-user -c "CREATE DATABASE kw_app_test;" postgres
```

### 3. Run migrations and seed
```bash
docker-compose run --rm -T app bundle exec rake db:migrate db:seed
```

### 4. Start all services
```bash
docker-compose up -d
```

### 5. Verify everything is running
```bash
docker-compose ps
```

## Database Reset (Drop & Recreate)

### Complete reset with all data loss
```bash
# Stop all containers
docker-compose down

# Start only database services
docker-compose up -d postgres redis mailcatcher
sleep 5

# Drop and recreate databases
docker-compose exec -T postgres psql -U dev-user -c "DROP DATABASE IF EXISTS kw_app_development;" postgres
docker-compose exec -T postgres psql -U dev-user -c "DROP DATABASE IF EXISTS kw_app_test;" postgres
docker-compose exec -T postgres psql -U dev-user -c "CREATE DATABASE kw_app_development;" postgres
docker-compose exec -T postgres psql -U dev-user -c "CREATE DATABASE kw_app_test;" postgres

# Run migrations and seed
docker-compose run --rm -T app bundle exec rake db:migrate db:seed

# Start all services
docker-compose up -d
```

## Database Configuration

### Connecting from host machine
```yaml
host: localhost
port: 5433
database: kw_app_development
username: dev-user
password: dev-password
```

### Connecting from within Docker containers
```yaml
host: postgres
port: 5432
database: kw_app_development
username: dev-user
password: dev-password
```

## Redis Configuration

### Connecting from host machine
```
redis://localhost:6380/1
```

### Connecting from within Docker containers
```
redis://redis:6379/1
```

## Common Commands

### Start all services
```bash
docker-compose up -d
```

### Stop all services
```bash
docker-compose down
```

### View logs
```bash
docker-compose logs -f
docker-compose logs -f app      # Rails app logs
docker-compose logs -f sidekiq  # Sidekiq logs
```

### Rebuild containers
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Run Rails commands
**Note: The service is called `app`, not `web`**

```bash
# Rails console
docker-compose exec app bundle exec rails console

# Run migrations
docker-compose exec app bundle exec rails db:migrate

# Run a rake task
docker-compose exec app bundle exec rake some:task

# Using -T flag to avoid TTY issues
docker-compose exec -T app bundle exec rails db:migrate
```

### Run bundle install (if Gemfile changes)
```bash
docker-compose build
docker-compose up -d
```

### Access PostgreSQL directly
```bash
docker-compose exec postgres psql -U dev-user kw_app_development
```

### Access Rails database via Rails console
```bash
docker-compose exec app bundle exec rails console
```

## Troubleshooting

### Port Already Allocated Error
If you see "port is already allocated", another container is using that port:
1. Check what's using the port: `lsof -i :PORT_NUMBER`
2. View other Docker containers: `docker ps -a`
3. Stop the conflicting container or change the port in `docker-compose.yml`

### Sidekiq "bundle install" Error
This was fixed by properly separating bundle gems from Rails cache:
- Bundle gems go to `/usr/local/bundle` (persisted via volume)
- Rails tmp goes to `/rails/tmp` (persisted via volume)
- Never set `BUNDLE_PATH` to a Rails directory

### Database Connection Issues
If migrations fail with "database does not exist":
1. Ensure PostgreSQL is running: `docker-compose ps postgres`
2. Create databases manually (see Database Reset section)
3. Check `config/database.yml` for correct settings

### TTY Issues with docker-compose exec
If you see "the input device is not a TTY" error:
- Add `-T` flag: `docker-compose exec -T app bundle exec rake db:migrate`
- Or use `docker-compose run --rm app` instead

### Clean Start (Nuclear Option)
```bash
# WARNING: This destroys all data including databases!
docker-compose down -v
docker volume prune -f
docker-compose build --no-cache
# Then follow "First Time Setup" instructions above
```

### Orphan Container Warning
If you see "Found orphan containers" warning:
```bash
docker-compose down --remove-orphans
```

## Network Configuration

Uses shared network `my_local_dev_network` to communicate with other Docker projects.

To make the network external and share it properly, add to `docker-compose.yml`:
```yaml
networks:
  my_local_dev_network:
    external: true
```

## Key Files
- `docker-compose.yml`: Service definitions and port mappings
- `Dockerfile`: Container build instructions
- `bin/docker-entrypoint`: Container startup script
- `config/database.yml`: Database configuration

## URLs When Running
- Rails App: http://localhost:3002
- Mailcatcher Web UI: http://localhost:1080
- PostgreSQL: localhost:5433
- Redis: localhost:6380