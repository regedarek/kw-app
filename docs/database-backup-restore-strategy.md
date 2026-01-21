# Database Backup & Restore Strategy

## Infrastructure Overview

- **Production Server**: 146.59.44.70 (OVH Cloud)
- **NAS**: FriendlyElec CM3588 (local network)
- **Raspberry Pi 5**: Mini rack (local network) - **Backup Orchestrator**
- **Laptop**: Developer workstation
- **Old Production Server**: 51.68.141.247 (migration source)

## Backup Flow (Automated)

```
Production Server (daily cron at 2am)
    ↓ creates dump locally
/var/backups/kw-app/db-YYYY-MM-DD.sql.gz
    ↓
    ↓ (Raspberry Pi 5 pulls via SSH - daily at 3am)
    ↓
Raspberry Pi 5 (/backups/kw-app/)
    ↓ validates & pushes to NAS
    ↓
CM3588 NAS (/backups/kw-app/)
    ↓
Keeps 3 latest backups on each location
```

## Backup Retention Policy

- **Production Server**: 2 latest dumps (disk space limited)
- **Raspberry Pi 5**: 3 latest dumps
- **CM3588 NAS**: 3 latest dumps (primary backup archive)

## Restore Scenarios

### Scenario 0: Initial Migration from Old Production Server

**Use Case**: One-time migration from old prod (51.68.141.247) to new prod (146.59.44.70)

**Location of dumps on old server**: `deploy@51.68.141.247:~/baza_dump/sql/`

**Available dumps**:
- `kw_app_production-20260104-000001.sql`
- `kw_app_production-20260111-000001.sql`
- `kw_app_production-20260114-142622.sql`
- `kw_app_production-20260118-000001.sql` (latest)

**Command**:
```bash
# Migrate latest dump from old to new production
bin/migrate-database-to-new-prod

# Or specify a specific dump
bin/migrate-database-to-new-prod --dump kw_app_production-20260118-000001.sql

# Dry run (download and verify, but don't restore)
bin/migrate-database-to-new-prod --dry-run
```

**Process**:
1. SSH to old prod server (51.68.141.247)
2. List available dumps, select latest (or specified dump)
3. Compress dump if not already compressed (add .gz)
4. Download to laptop `/tmp/migration-dump.sql.gz`
5. Verify dump integrity (not corrupted)
6. Upload to new prod server `/tmp/`
7. Restore via `kamal accessory exec postgres`
8. Verify restore (count tables, check recent records)
9. Clean up temp files on laptop and new prod
10. **Keep original on old server** (don't delete)

**After Migration**:
- Set up automated backups (Phase 1 & 2)
- Old server dumps remain as archive
- New automated flow takes over

---

### Scenario 1: Fresh Production Server Setup

**Use Case**: Deploying to a new production server for the first time

**Source Priority**:
1. CM3588 NAS (primary)
2. Raspberry Pi 5 (fallback)
3. Local file on laptop
4. Old production server (migration only)

**Command**:
```bash
# Auto-detect latest from NAS
bin/setup-fresh-production-db

# Specify source
bin/setup-fresh-production-db --from-nas
bin/setup-fresh-production-db --from-pi5
bin/setup-fresh-production-db --from-file /path/to/dump.sql.gz
bin/setup-fresh-production-db --from-ssh user@old-server:/path/dump.sql.gz
```

**Process**:
1. Script downloads dump from source to laptop `/tmp/`
2. Uploads dump to fresh prod server `/tmp/`
3. Restores via `kamal accessory exec postgres`
4. Verifies restore (table count, recent record check)
5. Cleans up temp files

---

### Scenario 2: Restore on Existing Production Server

**Use Case**: Rollback to previous version, data corruption recovery

**Source Priority**:
1. Local dump on prod server (fastest)
2. CM3588 NAS
3. Raspberry Pi 5

**Commands**:
```bash
# List available backups
bin/list-backups

# Restore from local prod dump (fastest - no download)
bin/restore-production-db --local db-2024-01-15.sql.gz

# Pull from NAS and restore
bin/restore-production-db --from-nas db-2024-01-10.sql.gz

# Pull from Pi5 (fallback)
bin/restore-production-db --from-pi5 db-2024-01-08.sql.gz
```

**Process**:
1. If `--local`: use existing dump on prod server
2. Else: download from source to prod `/tmp/`
3. Stop app container (optional, for consistency)
4. Restore dump via `kamal accessory exec postgres`
5. Verify restore
6. Restart app container
7. Cleanup

---

## Implementation Plan

### Phase 1: Production Server Backup Script

**File**: `/usr/local/bin/backup-db.sh` (on production server)

**What it does**:
- Creates PostgreSQL dump with timestamp
- Compresses with gzip
- Stores in `/var/backups/kw-app/db-YYYY-MM-DD.sql.gz`
- Rotates old dumps (keeps last 2)
- Logs to syslog

**Cron**: Daily at 2:00 AM UTC
```cron
0 2 * * * /usr/local/bin/backup-db.sh
```

**Installation**:
```bash
# Via Ansible or manual SSH
scp bin/install-prod-backup.sh ubuntu@146.59.44.70:/tmp/
ssh ubuntu@146.59.44.70 "sudo bash /tmp/install-prod-backup.sh"
```

---

### Phase 2: Raspberry Pi 5 Backup Orchestrator

**File**: `/home/pi/bin/backup-orchestrator.sh` (on Pi5)

**What it does**:
1. Pulls latest dump from production server via SSH/SCP
2. Validates dump integrity (gzip test)
3. Stores locally on Pi5 `/backups/kw-app/`
4. Pushes to CM3588 NAS via SSH/SCP
5. Rotates old dumps (keeps 3 latest on Pi5 and NAS)
6. Sends notifications on failure (optional: email/Slack)
7. Logs to `/var/log/backup-orchestrator.log`

**Cron**: Daily at 3:00 AM UTC (1 hour after prod creates dump)
```cron
0 3 * * * /home/pi/bin/backup-orchestrator.sh >> /var/log/backup-orchestrator.log 2>&1
```

**Setup Requirements**:
- SSH key from Pi5 to production server (read-only access to `/var/backups/`)
- SSH key from Pi5 to CM3588 NAS (write access to `/backups/kw-app/`)

---

### Phase 3: Laptop Restore Scripts

**Files** (in `kw-app/bin/`):

#### `bin/setup-fresh-production-db`
- For fresh server deployments
- Multi-source support (NAS, Pi5, local file, SSH)
- Downloads → Uploads → Restores → Verifies

#### `bin/restore-production-db`
- For existing production server
- Supports local dumps (no download) or remote sources
- Optional app container stop/start

#### `bin/list-backups`
- Shows available backups from all sources
- Displays: filename, size, date, source location
- Example output:
```
Available backups:

Production Server (146.59.44.70:/var/backups/kw-app/):
  db-2024-01-15.sql.gz  245MB  2024-01-15 02:05
  db-2024-01-14.sql.gz  243MB  2024-01-14 02:05

CM3588 NAS (nas.local:/backups/kw-app/):
  db-2024-01-15.sql.gz  245MB  2024-01-15 03:15
  db-2024-01-14.sql.gz  243MB  2024-01-14 03:15
  db-2024-01-13.sql.gz  241MB  2024-01-13 03:15

Raspberry Pi 5 (pi5.local:/backups/kw-app/):
  db-2024-01-15.sql.gz  245MB  2024-01-15 03:10
  db-2024-01-14.sql.gz  243MB  2024-01-14 03:10
  db-2024-01-13.sql.gz  241MB  2024-01-13 03:10
```

#### `bin/pull-prod-backups` (optional - manual trigger)
- Manually trigger what Pi5 does automatically
- Useful for ad-hoc backups

---

## Security Considerations

### SSH Key Setup

**Raspberry Pi 5 → Production Server**:
```bash
# On Pi5
ssh-keygen -t ed25519 -f ~/.ssh/id_prod_backup -C "pi5-backup"

# Add to prod server
ssh-copy-id -i ~/.ssh/id_prod_backup ubuntu@146.59.44.70

# Restrict key on prod server (edit ~/.ssh/authorized_keys)
command="scp -f /var/backups/kw-app/*",no-port-forwarding,no-X11-forwarding,no-agent-forwarding ssh-ed25519 AAAAC3...
```

**Raspberry Pi 5 → CM3588 NAS**:
```bash
# On Pi5
ssh-keygen -t ed25519 -f ~/.ssh/id_nas_backup -C "pi5-to-nas"

# Add to NAS
ssh-copy-id -i ~/.ssh/id_nas_backup user@nas.local
```

**Laptop → All Servers**:
- Use existing SSH keys
- No special restrictions needed (you're the admin)

---

## Monitoring & Alerts

### Success Indicators
- Pi5 backup log shows successful pull/push
- Latest dump exists on all 3 locations
- Dump sizes are reasonable (not 0 bytes, not 10x larger)
- AppSignal shows green status for backup automation

### Failure Alerts
- Pi5 backup script fails to pull from prod
- Pi5 cannot reach NAS
- Dump file corruption detected
- Disk space warnings
- AppSignal alerts on backup failures

### AppSignal Integration (Recommended)

**Purpose**: Track backup automation health and get alerted on failures

**Setup on Raspberry Pi 5**:

1. Install AppSignal Ruby gem or use HTTP API:
```bash
# Option 1: Use curl for HTTP API (simpler)
# No installation needed

# Option 2: Install Ruby gem (if you want more features)
gem install appsignal
```

2. Get AppSignal API key from Bitwarden:
```bash
# Store in Bitwarden item: "kw-app-appsignal-api-key"
# Fields:
#   - API Key: <your-api-key>
#   - App Name: kw-app-production
#   - Environment: production
```

3. Add to backup orchestrator script `/home/pi/bin/backup-orchestrator.sh`:

```bash
#!/bin/bash

# AppSignal configuration
APPSIGNAL_API_KEY="<from-bitwarden>"
APPSIGNAL_APP_NAME="kw-app-production"

# Send custom metric to AppSignal
send_appsignal_metric() {
    local metric_name=$1
    local value=$2
    local tags=$3
    
    curl -X POST "https://appsignal.com/api/metrics" \
      -H "Authorization: Bearer ${APPSIGNAL_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "{
        \"name\": \"${metric_name}\",
        \"value\": ${value},
        \"tags\": ${tags},
        \"timestamp\": $(date +%s)
      }"
}

# Send error to AppSignal
send_appsignal_error() {
    local error_message=$1
    local error_type=$2
    
    curl -X POST "https://appsignal.com/api/errors" \
      -H "Authorization: Bearer ${APPSIGNAL_API_KEY}" \
      -H "Content-Type: application/json" \
      -d "{
        \"error\": {
          \"message\": \"${error_message}\",
          \"type\": \"${error_type}\",
          \"backtrace\": []
        },
        \"environment\": \"production\",
        \"hostname\": \"$(hostname)\",
        \"timestamp\": $(date +%s)
      }"
}

# Track backup duration
start_time=$(date +%s)

# ... backup logic here ...

# On success
if [ $? -eq 0 ]; then
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    # Send success metric
    send_appsignal_metric "backup.duration" "${duration}" '{"status":"success","source":"pi5"}'
    send_appsignal_metric "backup.success" "1" '{"source":"pi5"}'
    
    echo "Backup completed successfully in ${duration}s"
else
    # Send failure metric
    send_appsignal_metric "backup.success" "0" '{"source":"pi5"}'
    send_appsignal_error "Backup orchestrator failed" "BackupError"
    
    echo "Backup failed!"
    exit 1
fi
```

**Metrics to Track**:
- `backup.duration` - How long backup takes (seconds)
- `backup.success` - 1 for success, 0 for failure
- `backup.size` - Size of backup file (bytes)
- `backup.prod_to_pi5.duration` - Time to pull from prod
- `backup.pi5_to_nas.duration` - Time to push to NAS

**Alerts to Set Up in AppSignal**:

1. **Backup Failure Alert**:
   - Condition: `backup.success == 0`
   - Notification: Slack/Email
   - Severity: Critical

2. **Backup Not Running**:
   - Condition: No `backup.success` metric received in 25 hours
   - Notification: Slack/Email
   - Severity: Critical

3. **Backup Taking Too Long**:
   - Condition: `backup.duration > 600` (10 minutes)
   - Notification: Slack
   - Severity: Warning

4. **Backup Size Anomaly**:
   - Condition: `backup.size` changes by >50% from previous day
   - Notification: Slack
   - Severity: Warning

**Dashboard in AppSignal**:
- Graph: Backup success rate (last 30 days)
- Graph: Backup duration trend
- Graph: Backup size over time
- Table: Last 7 days backup status
- Alert status: Green/Red indicator

### Alternative: HealthChecks.io
- Simpler alternative to AppSignal for backup monitoring
- Pi5 pings on successful backup
- Free tier available

---

## Migration Script Details

### `bin/migrate-database-to-new-prod`

**Purpose**: One-time migration from old production server to new production server

**Features**:
- Auto-detects latest dump on old server
- Handles both compressed (.gz) and uncompressed (.sql) dumps
- Compresses uncompressed dumps automatically
- Progress indicators for download/upload
- Integrity checks (file size, gzip test)
- Database verification after restore
- Cleanup on success or failure
- Option to keep dump on new server for future reference

**Requirements**:
- SSH access to old prod: `deploy@51.68.141.247`
- SSH access to new prod: `ubuntu@146.59.44.70`
- Kamal setup completed on new prod
- Postgres accessory running on new prod
- Sufficient disk space on laptop `/tmp/` (at least 2x dump size)

**Safety Features**:
- `--dry-run` mode for testing
- Does NOT delete dumps from old server
- Confirmation prompts before destructive actions
- Automatic rollback on failure
- Detailed logging

---

## Disaster Recovery Scenarios

### Scenario A: Production Database Corrupted
1. Run `bin/restore-production-db --local db-2024-01-14.sql.gz`
2. If local dumps corrupted: `--from-nas db-2024-01-14.sql.gz`
3. Verify data integrity
4. Resume operations

**Recovery Time**: 5-15 minutes (depending on dump size)

---

### Scenario B: Production Server Total Failure
1. Provision new server via Ansible/Kamal
2. Run `kamal setup -d production`
3. Run `bin/setup-fresh-production-db --from-nas`
4. Verify and go live

**Recovery Time**: 30-60 minutes (depending on provisioning)

---

### Scenario C: All Local Backups Lost (Pi5 + NAS Failure)
1. SSH to production server
2. Check `/var/backups/kw-app/` for local dumps
3. If available: use for restore
4. If not: restore from last known good state, accept data loss

**Prevention**: Consider cloud backup (S3/Backblaze) as 4th tier (optional)

---

### Scenario D: NAS Unreachable During Fresh Setup
1. Use `bin/setup-fresh-production-db --from-pi5`
2. Or use `--from-file` with local dump on laptop
3. After NAS recovers, sync backups

---

## Testing the Backup/Restore Process

### Monthly Backup Drill
1. Download latest dump from NAS
2. Restore to local Docker container
3. Verify data integrity (query recent records)
4. Document any issues

### Quarterly Disaster Recovery Test
1. Spin up fresh staging server
2. Full restore from NAS backup
3. Run smoke tests
4. Measure recovery time
5. Update runbooks

---

## Maintenance Tasks

### Weekly
- Check Pi5 backup logs for errors
- Verify backups exist on all 3 locations

### Monthly
- Test restore on local dev environment
- Check disk space on all backup locations
- Verify SSH keys still valid

### Quarterly
- Full disaster recovery drill
- Review and update documentation
- Check backup script for improvements

---

## Future Enhancements (Optional)

### Incremental Backups
- Use WAL archiving for point-in-time recovery
- Requires more complex setup

### Offsite Cloud Backup
- Sync to S3/Backblaze as 4th backup tier
- For catastrophic local failure

### Backup Encryption
- Encrypt dumps before storing
- Decrypt during restore
- Store encryption keys in Bitwarden

### Automated Testing
- Pi5 runs test restore in container weekly
- Validates dump integrity automatically

---

## Quick Reference

### Migrate from Old Production (One-Time)
```bash
# Download latest dump from old server and restore to new
bin/migrate-database-to-new-prod

# Dry run (test without restoring)
bin/migrate-database-to-new-prod --dry-run
```

### Create Backup (Manual)
```bash
ssh ubuntu@146.59.44.70 "sudo /usr/local/bin/backup-db.sh"
```

### List Backups
```bash
bin/list-backups
```

### Restore Fresh Server
```bash
bin/setup-fresh-production-db --from-nas
```

### Restore Existing Server
```bash
bin/restore-production-db --local latest
bin/restore-production-db --from-nas db-2024-01-15.sql.gz
```

### Check Backup Status
```bash
# View logs
ssh pi@pi5.local "tail -50 /var/log/backup-orchestrator.log"

# Check AppSignal dashboard
# Visit: https://appsignal.com/kw-app-production/dashboards
```

---

## Conclusion

This strategy provides:
- ✅ **Automated daily backups** via Raspberry Pi 5 orchestrator
- ✅ **3 backup copies** (prod server, Pi5, NAS)
- ✅ **Flexible restore** from multiple sources
- ✅ **Disaster recovery** capability
- ✅ **AppSignal monitoring** for backup health tracking
- ✅ **Simple maintenance** and monitoring

Next steps:
1. **FIRST**: Run migration from old production server
   - `bin/migrate-database-to-new-prod`
   - Verify data on new production
2. Implement Phase 1 (prod server backup script)
3. Implement Phase 2 (Pi5 orchestrator)
4. Implement Phase 3 (laptop restore scripts)
5. Set up AppSignal integration
6. Configure AppSignal alerts
7. Test end-to-end
8. Verify monitoring is working