---
name: performance-optimization
description: Performance optimization patterns for kw-app - N+1 query prevention, eager loading, caching strategies, and database optimization.
allowed-tools: Read, Write, Edit, Bash
---

# Performance Optimization (kw-app)

## Overview

Common performance patterns for Rails applications:
- N+1 query detection and prevention
- Eager loading strategies
- Database indexing
- Caching (fragment, action, HTTP)
- Background job optimization

## N+1 Query Prevention

### What is N+1?

```ruby
# ❌ N+1 Problem - 1 query + N queries
users = User.all  # 1 query
users.each do |user|
  puts user.posts.count  # N queries (one per user)
end
# Total: 1 + N queries

# ✅ Solution - 2 queries total
users = User.includes(:posts)  # 1 query + 1 eager load
users.each do |user|
  puts user.posts.count  # No query (already loaded)
end
# Total: 2 queries
```

### Detection

**Bullet Gem (already in kw-app):**

```ruby
# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
end
```

**Manual Detection:**

```ruby
# In Rails console
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Then run your code and watch the queries
User.all.each { |u| u.posts.count }
```

## Eager Loading Strategies

### includes (Most Common)

```ruby
# Loads associations with separate queries
users = User.includes(:posts, :comments)

# Generates:
# SELECT * FROM users
# SELECT * FROM posts WHERE user_id IN (1,2,3...)
# SELECT * FROM comments WHERE user_id IN (1,2,3...)
```

**When to use:**
- Need to access association records
- Multiple associations to load
- Default choice for eager loading

### preload (Force Separate Queries)

```ruby
# Always uses separate queries (even with conditions)
users = User.preload(:posts).where(posts: { published: true })

# Generates:
# SELECT * FROM users
# SELECT * FROM posts WHERE user_id IN (1,2,3...)
```

**When to use:**
- Want to guarantee separate queries
- Loading many associations
- Large datasets

### eager_load (Force LEFT OUTER JOIN)

```ruby
# Uses LEFT OUTER JOIN
users = User.eager_load(:posts).where(posts: { published: true })

# Generates:
# SELECT users.*, posts.* FROM users
# LEFT OUTER JOIN posts ON posts.user_id = users.id
# WHERE posts.published = true
```

**When to use:**
- Need to filter on association columns
- Smaller datasets
- Need SQL-level joins

### joins (Association Filter Only)

```ruby
# Only loads users, not posts
users = User.joins(:posts).where(posts: { published: true })

# Generates:
# SELECT users.* FROM users
# INNER JOIN posts ON posts.user_id = users.id
# WHERE posts.published = true
```

**When to use:**
- Only need to filter, not access associations
- Most efficient for filtering

## Common N+1 Patterns

### Pattern 1: Simple Association

```ruby
# ❌ N+1
@users = User.all
# In view: @users.each { |u| u.profile.name }

# ✅ Fixed
@users = User.includes(:profile)
```

### Pattern 2: Nested Associations

```ruby
# ❌ N+1
@users = User.all
# In view: @users.each { |u| u.posts.each { |p| p.comments.count } }

# ✅ Fixed
@users = User.includes(posts: :comments)
```

### Pattern 3: Multiple Associations

```ruby
# ❌ N+1
@users = User.all
# In view: user.profile, user.posts, user.settings

# ✅ Fixed
@users = User.includes(:profile, :posts, :settings)
```

### Pattern 4: Polymorphic Associations

```ruby
# ❌ N+1
@comments = Comment.all
# In view: comment.commentable (User or Post)

# ✅ Fixed
@comments = Comment.includes(:commentable)
```

### Pattern 5: Counting Associations

```ruby
# ❌ N+1 (loads all posts to count)
@users = User.includes(:posts)
# In view: user.posts.count

# ✅ Better - counter cache
class User < ApplicationRecord
  has_many :posts
end

class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
end

# Migration:
add_column :users, :posts_count, :integer, default: 0

# In view: user.posts_count (no query!)
```

## Database Indexing

### When to Add Index

```ruby
# ✅ Index foreign keys
add_index :posts, :user_id

# ✅ Index fields used in WHERE
add_index :users, :email
add_index :posts, :published_at

# ✅ Index unique fields
add_index :users, :email, unique: true

# ✅ Composite index for multiple conditions
add_index :posts, [:user_id, :published_at]

# ✅ Index for sorting
add_index :posts, :created_at
```

### Check Missing Indexes

```bash
# In Rails console
ActiveRecord::Base.connection.tables.each do |table|
  puts "Table: #{table}"
  columns = ActiveRecord::Base.connection.columns(table)
  foreign_keys = columns.select { |c| c.name.end_with?('_id') }
  foreign_keys.each do |fk|
    indexed = ActiveRecord::Base.connection.indexes(table).any? { |i| i.columns.include?(fk.name) }
    puts "  ⚠️  Missing index: #{fk.name}" unless indexed
  end
end
```

## Caching Strategies

### Fragment Caching (View Level)

```erb
<!-- app/views/posts/show.html.erb -->
<% cache @post do %>
  <h1><%= @post.title %></h1>
  <p><%= @post.body %></p>
<% end %>

<!-- Cache key: posts/123-20240115120000000000/... -->
```

**Auto-expires when:**
- `@post.updated_at` changes
- Template file changes

### Collection Caching

```erb
<!-- app/views/posts/index.html.erb -->
<%= render partial: 'post', collection: @posts, cached: true %>

<!-- Each post cached separately -->
```

### Russian Doll Caching

```erb
<!-- app/views/posts/show.html.erb -->
<% cache @post do %>
  <h1><%= @post.title %></h1>
  
  <% cache [@post, 'comments'] do %>
    <% @post.comments.each do |comment| %>
      <% cache comment do %>
        <%= render comment %>
      <% end %>
    <% end %>
  <% end %>
<% end %>
```

**touch: true to expire parent:**

```ruby
class Comment < ApplicationRecord
  belongs_to :post, touch: true
end

# When comment updates, post.updated_at also updates
# This expires the post cache
```

### Low-Level Caching

```ruby
# In model or service
class User
  def expensive_calculation
    Rails.cache.fetch("users/#{id}/calculation", expires_in: 1.hour) do
      # Expensive operation here
      perform_complex_calculation
    end
  end
end

# First call: runs calculation and caches
# Subsequent calls: returns cached value
```

### Cache Invalidation

```ruby
# Expire specific cache
Rails.cache.delete("users/#{user.id}/calculation")

# Expire by pattern (Redis)
Rails.cache.delete_matched("users/*/calculation")

# Clear all cache
Rails.cache.clear
```

## Query Optimization

### Select Only Needed Columns

```ruby
# ❌ Loads all columns
users = User.all

# ✅ Only needed columns
users = User.select(:id, :email, :name)
```

### Use pluck for Simple Attributes

```ruby
# ❌ Instantiates objects
user_ids = User.all.map(&:id)

# ✅ Returns array directly
user_ids = User.pluck(:id)

# ✅ Multiple columns
emails_and_names = User.pluck(:email, :name)
# => [["user1@example.com", "User 1"], ...]
```

### Batch Processing

```ruby
# ❌ Loads all records at once
User.all.each do |user|
  user.process
end

# ✅ Loads in batches (default 1000)
User.find_each do |user|
  user.process
end

# ✅ Custom batch size
User.find_each(batch_size: 500) do |user|
  user.process
end

# ✅ With conditions
User.where(active: true).find_each do |user|
  user.process
end
```

### exists? vs any?/present?

```ruby
# ❌ Loads all records
if User.where(email: email).any?
  # ...
end

# ✅ Only checks existence
if User.where(email: email).exists?
  # ...
end

# SQL: SELECT 1 FROM users WHERE email = '...' LIMIT 1
```

## Background Job Optimization

### Batch Jobs Instead of Individual

```ruby
# ❌ N jobs for N users
users.each do |user|
  SendEmailJob.perform_later(user.id)
end

# ✅ 1 job with batch
SendBatchEmailJob.perform_later(users.pluck(:id))

# SendBatchEmailJob
class SendBatchEmailJob < ApplicationJob
  def perform(user_ids)
    users = User.where(id: user_ids).includes(:profile)
    users.find_each do |user|
      UserMailer.notification(user).deliver_now
    end
  end
end
```

### Avoid Serializing Large Objects

```ruby
# ❌ Serializes entire user object
NotificationJob.perform_later(user)

# ✅ Pass only ID
NotificationJob.perform_later(user.id)

# In job:
def perform(user_id)
  user = User.find_by(id: user_id)
  return unless user
  # Process user
end
```

## Monitoring Performance

### In Development

```ruby
# config/environments/development.rb

# Log slow queries
config.active_record.verbose_query_logs = true

# Bullet for N+1
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
end
```

### In Production

**Check slow queries:**

```sql
-- PostgreSQL
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;
```

**Rails logs:**

```bash
# Find slow requests
grep "Completed 200" log/production.log | awk '{print $NF}' | sort -n | tail
```

## Quick Checklist

Before deploying, check:

- [ ] No N+1 queries (run with Bullet enabled)
- [ ] Foreign keys indexed
- [ ] Counter caches for counts
- [ ] Fragment caching on expensive views
- [ ] Batch processing for large datasets
- [ ] Background jobs for slow operations
- [ ] Database queries use `includes` where needed
- [ ] No unnecessary column loading (`select` or `pluck`)

## Common Mistakes

### ❌ Mistake 1: Over-eager loading

```ruby
# ❌ Loads everything (unnecessary)
users = User.includes(:posts, :comments, :profile, :settings, :notifications)

# ✅ Only load what's needed
users = User.includes(:posts)  # Only need posts
```

### ❌ Mistake 2: Caching without expiration

```ruby
# ❌ Never expires
Rails.cache.fetch("stats") do
  calculate_stats
end

# ✅ Has expiration
Rails.cache.fetch("stats", expires_in: 1.hour) do
  calculate_stats
end
```

### ❌ Mistake 3: N+1 in JSON rendering

```ruby
# ❌ N+1 in serializer
class UserSerializer
  def posts
    object.posts.map { |p| PostSerializer.new(p) }
  end
end

# Controller has N+1:
@users = User.all  # Need includes!

# ✅ Fixed
@users = User.includes(:posts)
```

## Tools & Resources

- **Bullet**: N+1 detection
- **rack-mini-profiler**: Per-request profiling
- **pg_stat_statements**: PostgreSQL query analysis
- **New Relic/Scout**: Production monitoring
- **kw-app Monitoring**: Check Sidekiq web UI at `/sidekiq`

## Quick Reference

| Problem | Solution |
|---------|----------|
| N+1 queries | `includes`, `preload`, `eager_load` |
| Slow counts | Counter cache |
| Large datasets | `find_each`, `find_in_batches` |
| Expensive views | Fragment caching |
| Slow calculations | Low-level caching |
| Missing indexes | `add_index` |
| Full column load | `select`, `pluck` |

---

**Version**: 2.0  
**Last Updated**: 2024-01  
**Maintained By**: kw-app team