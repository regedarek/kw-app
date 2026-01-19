## Getting started

### Prerequisites

docker, kamal ,docker-compose

### First build

Within terminal:

```bash
# 1. Build containers
docker-compose build

# 2. Start database services
docker-compose up -d postgres redis mailcatcher
sleep 5

# 3. Create databases
docker-compose exec -T postgres psql -U dev-user -c "CREATE DATABASE kw_app_development;" postgres
docker-compose exec -T postgres psql -U dev-user -c "CREATE DATABASE kw_app_test;" postgres

# 4. Run migrations and seed
docker-compose run --rm -T app bundle exec rake db:migrate db:seed

# 5. Install JavaScript dependencies (yarn)
docker-compose up -d
docker-compose exec -T --user root app bash -c "apt-get update && apt-get install -y python2 && ln -sf /usr/bin/python2 /usr/bin/python && yarn install && chown -R rails:rails /rails/node_modules"

# 6. Verify everything is running
docker-compose ps
```

**Note:** The service is called `app`, not `web`. See [DOCKER_SETUP.md](DOCKER_SETUP.md) for detailed documentation.

Go to [localhost:3002](http://localhost:3002). Enjoy!

### Environments & Deployment

#### Staging (Raspberry Pi - Manual Deployment)

**SSH Access:**
```bash
ssh rege@pi5main.local
```

**Manual Deployment:**
```bash
# SSH into the Raspberry Pi
ssh rege@pi5main.local

# Navigate to project directory
cd ~/kw-app

# Pull latest changes
git pull origin staging

# Deploy with Kamal (staging environment)
kamal deploy -d staging
```

**Environment Details:**
- Host: `pi5main.local`
- Architecture: ARM64
- User: `rege`
- Services: PostgreSQL (port 5433), Redis (port 6381)

#### Production (VPS - Automated Deployment)

**SSH Access:**
```bash
ssh ubuntu@146.59.44.70
```

**Deployment:**
- **Automated**: Push to `secrets-management` branch triggers GitHub Actions workflow
- **Manual**: SSH into server and run `kamal deploy -d production` if needed

**GitHub Actions:**
- Automatic deployment on push to `secrets-management`
- Runs tests before deployment
- Zero-downtime deployment via Kamal

**View Logs:**
```bash
# SSH into production server
ssh ubuntu@146.59.44.70

# View app logs
kamal app logs -f -d production
```

**Environment Details:**
- Host: `146.59.44.70`
- User: `ubuntu`
- Deployment: Automated via GitHub Actions


### Development

Debugging
```bash
docker attach $(docker-compose ps -q app)
# Or view logs:
docker-compose logs -f app
```

**Local Services:**
- Web (panel): [localhost:3002](http://localhost:3002)
- MailCatcher (mail debugging tool): [localhost:1080](http://localhost:1080)
- Sidekiq (queue): [localhost:3002/sidekiq](http://localhost:3002/sidekiq)

**Database Connections:**
- PostgreSQL: `localhost:5433` (inside containers: `postgres:5432`)
- Redis: `localhost:6380` (inside containers: `redis:6379`)

**Common Commands:**
```bash
# Run Rails console
docker-compose exec app bundle exec rails console

# Run migrations
docker-compose exec -T app bundle exec rake db:migrate

# Reset database
docker-compose exec -T postgres psql -U dev-user -c "DROP DATABASE IF EXISTS kw_app_development;" postgres
docker-compose exec -T postgres psql -U dev-user -c "CREATE DATABASE kw_app_development;" postgres
docker-compose run --rm -T app bundle exec rake db:migrate db:seed
```

For more details, see [DOCKER_SETUP.md](DOCKER_SETUP.md)


###

[![Code Climate](https://codeclimate.com/github/regedarek/kw-app.svg)](https://codeclimate.com/github/regedarek/kw-app)
[![Security](https://hakiri.io/github/regedarek/kw-app/master.svg)](https://hakiri.io/github/regedarek/kw-app/master)
[![Staging](https://kw-app-staging.herokuapp.com)](https://kw-app-staging.herokuapp.com)
