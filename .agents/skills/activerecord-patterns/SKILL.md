---
name: activerecord-patterns
description: ActiveRecord model patterns and best practices for kw-app - validations, associations, scopes, queries, and when to keep models thin.
allowed-tools: Read, Write, Edit, Bash
---

# ActiveRecord Patterns (kw-app)

## Overview

Best practices for ActiveRecord models in kw-app:
- Keep models thin (data + persistence only)
- Delegate business logic to services
- Use proper validations and associations
- Optimize queries to prevent N+1
- Write comprehensive tests

## Model Philosophy

**Models should be thin** - they handle:
- ✅ Data structure (schema)
- ✅ Validations (data integrity)
- ✅ Associations (relationships)
- ✅ Scopes (common queries)
- ✅ Simple query methods
- ❌ NOT business logic (use services)
- ❌ NOT complex calculations (use services)
- ❌ NOT external API calls (use services)

## Basic Model Structure

```ruby
# app/models/db/user.rb
module Db
  class User < ApplicationRecord
    # Associations
    belongs_to :company
    has_many :posts, dependent: :destroy
    has_many :comments, dependent: :nullify
    has_one :profile, dependent: :destroy
    
    # Validations
    validates :email, presence: true, uniqueness: { case_sensitive: false }
    validates :name, presence: true, length: { minimum: 2, maximum: 100 }
    validates :status, inclusion: { in: %w[active inactive suspended] }
    
    # Callbacks (use sparingly!)
    before_save :normalize_email
    
    # Scopes
    scope :active, -> { where(status: 'active') }
    scope :recent, -> { order(created_at: :desc) }
    scope :with_profile, -> { includes(:profile) }
    
    # Simple query methods
    def active?
      status == 'active'
    end
    
    def full_name
      "#{first_name} #{last_name}".strip
    end
    
    private
    
    def normalize_email
      self.email = email.downcase.strip if email.present?
    end
  end
end
```

## Associations

### belongs_to

```ruby
class Post < ApplicationRecord
  belongs_to :user
  belongs_to :category, optional: true
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
end
```

**Options:**
- `optional: true` - Allow nil (Rails 5+ requires by default)
- `class_name: 'Model'` - Different class name
- `foreign_key: 'field_id'` - Custom foreign key
- `counter_cache: true` - Add `posts_count` to parent
- `touch: true` - Update parent's `updated_at`

### has_many

```ruby
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :nullify
  has_many :favorites, dependent: :delete_all
  has_many :published_posts, -> { where(published: true) }, class_name: 'Post'
end
```

**dependent: options:**
- `:destroy` - Call destroy on each child (runs callbacks)
- `:delete_all` - Direct SQL DELETE (no callbacks, faster)
- `:nullify` - Set foreign key to NULL
- `:restrict_with_error` - Prevent deletion if children exist

### has_one

```ruby
class User < ApplicationRecord
  has_one :profile, dependent: :destroy
  has_one :latest_post, -> { order(created_at: :desc) }, class_name: 'Post'
end
```

### has_many :through

```ruby
class User < ApplicationRecord
  has_many :memberships
  has_many :groups, through: :memberships
end

class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :group
end

class Group < ApplicationRecord
  has_many :memberships
  has_many :users, through: :memberships
end
```

### Polymorphic Associations

```ruby
class Comment < ApplicationRecord
  belongs_to :commentable, polymorphic: true
end

class Post < ApplicationRecord
  has_many :comments, as: :commentable
end

class Photo < ApplicationRecord
  has_many :comments, as: :commentable
end
```

**Migration:**
```ruby
create_table :comments do |t|
  t.references :commentable, polymorphic: true, index: true
  t.text :body
  t.timestamps
end
```

## Validations

### Built-in Validations

```ruby
class User < ApplicationRecord
  # Presence
  validates :email, presence: true
  validates :name, presence: { message: "can't be blank" }
  
  # Uniqueness
  validates :email, uniqueness: true
  validates :slug, uniqueness: { case_sensitive: false, scope: :company_id }
  
  # Length
  validates :name, length: { minimum: 2, maximum: 100 }
  validates :bio, length: { maximum: 500, allow_blank: true }
  
  # Format
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, format: { with: /\A[a-zA-Z0-9_]+\z/ }
  
  # Numericality
  validates :age, numericality: { greater_than: 0, less_than: 150 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  
  # Inclusion/Exclusion
  validates :status, inclusion: { in: %w[draft published archived] }
  validates :username, exclusion: { in: %w[admin root] }
  
  # Confirmation
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
  
  # Acceptance
  validates :terms_of_service, acceptance: true
end
```

### Custom Validations

```ruby
class Booking < ApplicationRecord
  validate :end_date_after_start_date
  
  private
  
  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    
    if end_date < start_date
      errors.add(:end_date, 'must be after start date')
    end
  end
end
```

### Conditional Validations

```ruby
class User < ApplicationRecord
  validates :password, presence: true, if: :password_required?
  validates :admin_code, presence: true, if: :admin?
  validates :bio, length: { maximum: 500 }, unless: :guest?
  
  private
  
  def password_required?
    new_record? || password.present?
  end
  
  def admin?
    role == 'admin'
  end
  
  def guest?
    role == 'guest'
  end
end
```

### Custom Validators

```ruby
# app/validators/email_validator.rb
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ URI::MailTo::EMAIL_REGEXP
      record.errors.add(attribute, options[:message] || 'is not a valid email')
    end
  end
end

# Usage in model
class User < ApplicationRecord
  validates :email, email: true
end
```

## Scopes

### Basic Scopes

```ruby
class Post < ApplicationRecord
  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
end

# Usage
Post.published.recent
```

### Scopes with Arguments

```ruby
class Post < ApplicationRecord
  scope :by_status, ->(status) { where(status: status) }
  scope :created_after, ->(date) { where('created_at > ?', date) }
  scope :by_author, ->(author_id) { where(author_id: author_id) }
end

# Usage
Post.by_status('published').created_after(1.week.ago)
```

### Default Scope (use sparingly!)

```ruby
class Post < ApplicationRecord
  default_scope { where(deleted: false).order(created_at: :desc) }
end

# Override default scope
Post.unscoped.all
```

### Chainable Scopes

```ruby
class User < ApplicationRecord
  scope :active, -> { where(status: 'active') }
  scope :verified, -> { where(verified: true) }
  scope :admin, -> { where(role: 'admin') }
end

# Chain scopes
User.active.verified.admin
```

## Query Patterns

### Eager Loading (Prevent N+1)

```ruby
# ❌ N+1 Query
users = User.all
users.each { |user| puts user.posts.count }

# ✅ Eager Load
users = User.includes(:posts)
users.each { |user| puts user.posts.count }

# Multiple associations
User.includes(:posts, :comments, :profile)

# Nested associations
User.includes(posts: [:comments, :tags])
```

### Joins

```ruby
# Inner join
User.joins(:posts).where(posts: { published: true })

# Left outer join (eager_load)
User.eager_load(:posts).where(posts: { published: true })

# Multiple joins
User.joins(:posts, :comments)
```

### Select Specific Columns

```ruby
# Only specific columns
User.select(:id, :email, :name)

# With SQL functions
User.select('users.*, COUNT(posts.id) as posts_count')
    .joins(:posts)
    .group('users.id')
```

### Pluck (Direct Array)

```ruby
# Single column
User.pluck(:email)
# => ["user1@example.com", "user2@example.com"]

# Multiple columns
User.pluck(:id, :email)
# => [[1, "user1@example.com"], [2, "user2@example.com"]]
```

### Find vs Find_by

```ruby
# Raises ActiveRecord::RecordNotFound if not found
user = User.find(1)

# Returns nil if not found
user = User.find_by(email: 'user@example.com')

# With bang! raises if not found
user = User.find_by!(email: 'user@example.com')
```

### Batch Processing

```ruby
# find_each (batches of 1000)
User.find_each do |user|
  user.process
end

# Custom batch size
User.find_each(batch_size: 500) do |user|
  user.process
end

# find_in_batches
User.find_in_batches(batch_size: 1000) do |users|
  users.each { |user| user.process }
end
```

## Callbacks

### Available Callbacks

```ruby
class User < ApplicationRecord
  # Creating
  before_validation
  after_validation
  before_save
  around_save
  before_create
  around_create
  after_create
  after_save
  
  # Updating
  before_update
  around_update
  after_update
  
  # Destroying
  before_destroy
  around_destroy
  after_destroy
  
  # Other
  after_commit
  after_rollback
  after_find
  after_initialize
end
```

### Callback Best Practices

**✅ Good - Data normalization:**
```ruby
class User < ApplicationRecord
  before_save :normalize_email
  
  private
  
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
```

**❌ Bad - Business logic:**
```ruby
class User < ApplicationRecord
  after_create :send_welcome_email  # Should be in service!
  after_update :notify_admin        # Should be in service!
end
```

**✅ Better - Service handles business logic:**
```ruby
# Service
class Users::Operation::Create
  def call(params:)
    user = yield persist(params)
    yield send_welcome_email(user)
    Success(user)
  end
end
```

### Conditional Callbacks

```ruby
class User < ApplicationRecord
  before_save :encrypt_password, if: :password_changed?
  after_update :send_notification, unless: :guest?
end
```

## Counter Caches

### Setup

```ruby
# Migration
class AddPostsCountToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :posts_count, :integer, default: 0, null: false
  end
end

# Model
class Post < ApplicationRecord
  belongs_to :user, counter_cache: true
end

class User < ApplicationRecord
  has_many :posts
end

# Usage (no query!)
user.posts_count
```

### Reset Counter Cache

```ruby
User.reset_counters(user_id, :posts)
```

## Enums

```ruby
class Post < ApplicationRecord
  enum status: {
    draft: 0,
    published: 1,
    archived: 2
  }
end

# Usage
post.draft!
post.draft?       # => true
post.published?   # => false

Post.draft        # => all draft posts
Post.published    # => all published posts
```

**With prefix/suffix:**
```ruby
class Post < ApplicationRecord
  enum status: { draft: 0, published: 1 }, _prefix: :status
  enum visibility: { public: 0, private: 1 }, _suffix: true
end

post.status_draft?
post.public_visibility?
```

## Indexes

### When to Add Indexes

```ruby
# Foreign keys
add_index :posts, :user_id

# Unique constraints
add_index :users, :email, unique: true

# Frequently queried fields
add_index :posts, :published_at
add_index :posts, :status

# Composite indexes (order matters!)
add_index :posts, [:user_id, :published_at]
add_index :posts, [:status, :created_at]

# Conditional indexes (PostgreSQL)
add_index :posts, :slug, where: "deleted_at IS NULL"
```

## Transactions

```ruby
ActiveRecord::Base.transaction do
  user = User.create!(email: 'user@example.com')
  profile = Profile.create!(user: user, bio: 'Bio')
  Membership.create!(user: user, group: group)
end
# All or nothing - rolls back if any fails
```

## Testing Models

### Association Tests

```ruby
RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_one(:profile).dependent(:destroy) }
    it { should belong_to(:company) }
  end
end
```

### Validation Tests

```ruby
RSpec.describe User, type: :model do
  describe 'validations' do
    subject { build(:user) }
    
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_length_of(:name).is_at_least(2).is_at_most(100) }
    it { should validate_inclusion_of(:status).in_array(%w[active inactive]) }
  end
end
```

### Scope Tests

```ruby
RSpec.describe Post, type: :model do
  describe 'scopes' do
    describe '.published' do
      let!(:published_post) { create(:post, published: true) }
      let!(:draft_post) { create(:post, published: false) }
      
      it 'returns only published posts' do
        expect(Post.published).to contain_exactly(published_post)
      end
    end
  end
end
```

## Common Anti-Patterns

### ❌ Fat Models

```ruby
class User < ApplicationRecord
  def register_and_notify
    # 50 lines of business logic
    # Email sending
    # External API calls
    # Complex validation
  end
end
```

**Fix: Extract to service**

### ❌ Callbacks for Business Logic

```ruby
class User < ApplicationRecord
  after_create :send_welcome_email
  after_create :create_default_profile
  after_create :notify_admin
  after_create :update_statistics
end
```

**Fix: Use service objects**

### ❌ Missing dependent: on associations

```ruby
class User < ApplicationRecord
  has_many :posts  # Orphaned posts when user deleted!
end
```

**Fix: Add dependent:**
```ruby
has_many :posts, dependent: :destroy
```

## Decision Tree

```
Where should this code go?

Is it data structure/schema? → Model (as attribute/column)
Is it data validation? → Model (validates)
Is it a relationship? → Model (belongs_to/has_many)
Is it a common query? → Model (scope)
Is it data formatting? → Model (simple method like full_name)

Is it business logic? → Service Object
Is it complex calculation? → Service Object
Is it external API call? → Service Object
Is it multi-step process? → Service Object
```

## Quick Reference

| Task | Pattern |
|------|---------|
| Define relationship | `belongs_to`, `has_many`, `has_one` |
| Validate data | `validates` |
| Common query | `scope` |
| Prevent N+1 | `includes`, `preload`, `eager_load` |
| Batch processing | `find_each`, `find_in_batches` |
| Counter cache | `counter_cache: true` |
| Soft delete | `scope :active, -> { where(deleted_at: nil) }` |
| Enum | `enum status: { draft: 0, published: 1 }` |
| Transaction | `ActiveRecord::Base.transaction do ... end` |

## Additional Resources

- **Official Guides**: https://guides.rubyonrails.org/active_record_basics.html
- **Testing**: [testing-standards skill](../testing-standards/SKILL.md)
- **Performance**: [performance-optimization skill](../performance-optimization/SKILL.md)
- **Services**: [rails-service-object skill](../rails-service-object/SKILL.md)
- **kw-app Policy**: See CLAUDE.md section on models

---

**Version**: 2.0  
**Last Updated**: 2024-01  
**Maintained By**: kw-app team