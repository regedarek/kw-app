# Claude AI Agent Guidelines for kw-app

## 🚫 Restrictions

**NEVER perform git operations:**
- ❌ `git commit`
- ❌ `git push`
- ❌ `git pull`
- ❌ `git merge`
- ❌ Any other git commands that modify repository state

All version control operations must be performed by human developers.

## 🔐 SSH Access

### Production Server
```bash
ssh deploy@51.68.141.247
```

### Key Information
- **Deployment tool**: Kamal (Docker-based deployment)
- **Infrastructure**: OpenStack
- **File storage**: CarrierWave
- **Containerization**: Docker

## 📋 Viewing Logs

### Local Development Logs

**Docker Compose Logs:**
```bash
# Follow all service logs
docker-compose logs -f

# Follow specific service (app)
docker-compose logs -f app

# View last 100 lines
docker-compose logs --tail=100 app

# View Postgres logs
docker-compose logs -f postgres

# View Redis logs
docker-compose logs -f redis
```

**Attach to Running Container:**
```bash
docker attach $(docker-compose ps -q app)
```

**Rails Logs Inside Container:**
```bash
docker-compose exec app tail -f log/development.log
docker-compose exec app tail -f log/test.log
```

### Production Logs (via Kamal)

**After SSH into server:**
```bash
# View app logs
kamal app logs

# Follow logs (real-time)
kamal app logs -f

# View specific container logs
docker logs <container-id>

# Follow specific container
docker logs -f <container-id>

# List running containers
docker ps
```

## 🛠️ Common Debugging Commands

```bash
# Check service status
docker-compose ps

# Restart services
docker-compose restart app

# View Sidekiq logs (background jobs)
docker-compose logs -f app | grep -i sidekiq

# Rails console
docker-compose exec app bundle exec rails console

# Check disk space (production)
df -h

# Check memory usage (production)
free -m
```

## 📦 Technology Stack Reference

- **chruby**: Ruby version manager (used for Ruby version switching)
- **Kamal**: Modern deployment tool (successor to Capistrano for Docker)
- **OpenStack**: Cloud infrastructure platform
- **CarrierWave**: File upload/storage gem for Rails
- **Docker**: Containerization platform
- **PostgreSQL**: Primary database (port 5433 locally)
- **Redis**: Cache/queue backend (port 6380 locally)
- **Sidekiq**: Background job processing

## ⚠️ Important Notes

- Always verify changes in development before suggesting production modifications
- Database migrations should be reviewed carefully before execution
- CarrierWave uploads stored according to configuration (check `config/initializers/carrierwave.rb`)
- Kamal deployments are zero-downtime by default