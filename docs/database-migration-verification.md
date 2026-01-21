# Database Migration Verification Checklist

## Overview
After migrating the database from old production (51.68.141.247) to new production (146.59.44.70), use this checklist to verify the migration was successful.

**Migration Date**: _____________________
**Performed By**: _____________________
**Dump Used**: kw_app_production-20260118-000001.sql

---

## Phase 1: Database Structure Verification

### 1.1 Table Count
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -t -c \"SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public';\""
```
**Expected**: 101 tables
**Actual**: _____

✅ / ❌

---

### 1.2 PostgreSQL Extensions
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c '\dx'"
```
**Expected Extensions**:
- plpgsql (1.0)

✅ / ❌

---

### 1.3 Key Tables Exist
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c \"SELECT table_name FROM information_schema.tables WHERE table_schema='public' ORDER BY table_name;\""
```

**Critical tables to verify**:
- [ ] users
- [ ] profiles
- [ ] contracts
- [ ] events
- [ ] payments
- [ ] products
- [ ] reservations
- [ ] schema_migrations
- [ ] ar_internal_metadata

✅ / ❌

---

## Phase 2: Data Integrity Verification

### 2.1 Total Record Counts

#### Users Table
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -t -c 'SELECT COUNT(*) FROM users;'"
```
**Expected**: ~10,442 (from old prod)
**Actual**: _____

✅ / ❌

---

#### Profiles Table
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -t -c 'SELECT COUNT(*) FROM profiles;'"
```
**Expected**: ~43,775
**Actual**: _____

✅ / ❌

---

#### Photos Table
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -t -c 'SELECT COUNT(*) FROM photos;'"
```
**Expected**: ~132,106
**Actual**: _____

✅ / ❌

---

#### Notifications Table
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -t -c 'SELECT COUNT(*) FROM notifications;'"
```
**Expected**: ~21,697
**Actual**: _____

✅ / ❌

---

### 2.2 Sample Data Verification

#### Check Recent User
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c 'SELECT id, email, created_at FROM users ORDER BY id DESC LIMIT 5;'"
```
**Verify**: Recent users exist with expected data

✅ / ❌

---

#### Check Recent Events
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c 'SELECT id, title, created_at FROM events ORDER BY id DESC LIMIT 5;'"
```
**Verify**: Recent events exist

✅ / ❌

---

### 2.3 Schema Version
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c 'SELECT version FROM schema_migrations ORDER BY version DESC LIMIT 5;'"
```
**Verify**: Latest migration version matches old production

✅ / ❌

---

## Phase 3: Database Configuration Verification

### 3.1 Database Owner
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d postgres -c \"SELECT datname, pg_catalog.pg_get_userbyid(datdba) as owner FROM pg_database WHERE datname='kw_app_production';\""
```
**Expected Owner**: production_user

✅ / ❌

---

### 3.2 Database Encoding
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c 'SHOW SERVER_ENCODING;'"
```
**Expected**: UTF8

✅ / ❌

---

### 3.3 Sequences Status
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c \"SELECT schemaname, sequencename, last_value FROM pg_sequences WHERE schemaname='public' ORDER BY sequencename LIMIT 10;\""
```
**Verify**: Sequences have non-zero values

✅ / ❌

---

## Phase 4: Application-Level Verification

### 4.1 Rails Console Access
```bash
# Access Rails console
kamal app exec -d production -i "bin/rails console"
```

In console, run:
```ruby
# Check user count
User.count
# Expected: ~10,442

# Check latest user
User.last
# Should show recent user data

# Check database connection
ActiveRecord::Base.connection.active?
# Expected: true

# Check a complex query
Event.joins(:participants).count
# Should execute without errors
```

✅ / ❌

---

### 4.2 Application Boot Test
```bash
# Check if app is running
kamal app details -d production
```
**Verify**: App container is healthy

✅ / ❌

---

### 4.3 Health Check Endpoint
```bash
curl https://nowypanel.kw.krakow.pl/up
```
**Expected**: HTTP 200 OK

✅ / ❌

---

## Phase 5: Functional Testing

### 5.1 User Authentication
**Manual Test**:
1. Visit: https://nowypanel.kw.krakow.pl
2. Attempt to log in with a known user account
3. Verify dashboard loads

✅ / ❌

---

### 5.2 Data Display
**Manual Test**:
1. Navigate to users list
2. Verify users are displayed
3. Open a user profile
4. Verify profile data is correct

✅ / ❌

---

### 5.3 Search Functionality
**Manual Test**:
1. Use search feature
2. Verify search results are returned
3. Verify search is not empty

✅ / ❌

---

### 5.4 Recent Activity
**Manual Test**:
1. Check recent events/activities
2. Verify timestamps are correct (not future dates)
3. Verify data integrity

✅ / ❌

---

## Phase 6: Performance Checks

### 6.1 Database Size
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c \"SELECT pg_size_pretty(pg_database_size('kw_app_production'));\""
```
**Actual Size**: _____

✅ / ❌

---

### 6.2 Index Status
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c \"SELECT schemaname, tablename, indexname FROM pg_indexes WHERE schemaname='public' ORDER BY tablename LIMIT 20;\""
```
**Verify**: Indexes exist on key tables

✅ / ❌

---

### 6.3 Query Performance Test
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c \"EXPLAIN ANALYZE SELECT * FROM users WHERE email LIKE '%@example.com' LIMIT 10;\""
```
**Verify**: Query executes in reasonable time (<100ms)

✅ / ❌

---

## Phase 7: Data Consistency Checks

### 7.1 Foreign Key Constraints
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c \"SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_type='FOREIGN KEY' AND table_schema='public';\""
```
**Verify**: Foreign key constraints exist

✅ / ❌

---

### 7.2 Check for NULL Issues
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c \"SELECT COUNT(*) FROM users WHERE email IS NULL;\""
```
**Expected**: 0 (or very low number)

✅ / ❌

---

### 7.3 Check Recent Timestamps
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c \"SELECT MAX(created_at) as latest_record FROM users;\""
```
**Verify**: Latest timestamp is before migration date (2026-01-18)

✅ / ❌

---

## Phase 8: Known Issues & Warnings

### 8.1 Expected Errors During Migration
The following errors during restoration are **EXPECTED** and **NOT CRITICAL**:

```
ERROR: role "deploy" does not exist
```

**Explanation**: The old production used the `deploy` user, but new production uses `production_user`. These errors only affect table ownership, not data integrity. All tables are owned by `production_user` on the new server.

**Verification**:
```bash
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c \"SELECT DISTINCT tableowner FROM pg_tables WHERE schemaname='public';\""
```
**Expected**: Only `production_user` should be listed.

✅ / ❌

---

## Phase 9: Post-Migration Tasks

### 9.1 Update Application Configuration
- [ ] Verify `DATABASE_URL` in production environment
- [ ] Verify `POSTGRES_USER` = production_user
- [ ] Verify `POSTGRES_DB` = kw_app_production
- [ ] Verify `DB_HOST` = kw-app-postgres

---

### 9.2 Set Up Automated Backups
- [ ] Install backup script on production server (Phase 1)
- [ ] Set up Raspberry Pi 5 orchestrator (Phase 2)
- [ ] Configure AppSignal monitoring
- [ ] Test backup script manually
- [ ] Verify backups are created in `/var/backups/kw-app/`

---

### 9.3 Monitor Application Logs
```bash
kamal app logs -d production --lines 100
```
**Check for**:
- Database connection errors
- Query errors
- Performance warnings

✅ / ❌

---

### 9.4 Update DNS (If Needed)
- [ ] Verify DNS points to new production IP: 146.59.44.70
- [ ] Test: `nslookup nowypanel.kw.krakow.pl`
- [ ] Verify SSL certificate is valid

---

## Summary

### Migration Statistics
- **Total Tables**: _____
- **Total Records**: _____ (sum of all tables)
- **Database Size**: _____
- **Migration Duration**: _____ minutes
- **Downtime**: _____ minutes

### Overall Status
- [ ] ✅ All critical checks passed
- [ ] ⚠️ Some warnings (document below)
- [ ] ❌ Migration failed (document issues below)

### Notes / Issues Found
_______________________________________
_______________________________________
_______________________________________

### Sign-Off
**Verified By**: _____________________
**Date**: _____________________
**Approved for Production**: ✅ / ❌

---

## Quick Verification Script

Save this as `bin/verify-migration` for automated checks:

```bash
#!/usr/bin/env bash
echo "=== Database Migration Verification ==="
echo ""
echo "1. Table Count:"
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -t -c 'SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='\''public'\'';'"
echo ""
echo "2. User Count:"
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -t -c 'SELECT COUNT(*) FROM users;'"
echo ""
echo "3. Photos Count:"
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -t -c 'SELECT COUNT(*) FROM photos;'"
echo ""
echo "4. Database Size:"
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -t -c 'SELECT pg_size_pretty(pg_database_size('\''kw_app_production'\''));'"
echo ""
echo "5. Latest User:"
ssh ubuntu@146.59.44.70 "docker exec kw-app-postgres psql -U production_user -d kw_app_production -c 'SELECT id, email, created_at FROM users ORDER BY id DESC LIMIT 1;'"
echo ""
echo "6. Health Check:"
curl -s -o /dev/null -w "%{http_code}" https://nowypanel.kw.krakow.pl/up
echo ""
```
