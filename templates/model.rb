# frozen_string_literal: true

# Template: ActiveRecord Model (Thin)
# Location: app/models/db/{{resource}}.rb
#
# Replace:
#   {{Resource}}  → PascalCase singular (e.g., User, BlogPost)
#   {{resource}}  → snake_case singular (e.g., user, blog_post)
#   {{resources}} → snake_case plural (e.g., users, blog_posts)

module Db
  class {{Resource}} < ApplicationRecord
    # === Associations ===
    # belongs_to :user
    # belongs_to :category, optional: true
    # has_many :comments, dependent: :destroy
    # has_one :profile, dependent: :destroy

    # === Validations ===
    # validates :name, presence: true, length: { minimum: 2, maximum: 100 }
    # validates :email, presence: true, uniqueness: { case_sensitive: false }
    # validates :status, inclusion: { in: %w[draft published archived] }

    # === Enums (Rails 7+) ===
    # enum :status, { draft: 0, published: 1, archived: 2 }, prefix: true

    # === Scopes ===
    # scope :active, -> { where(active: true) }
    # scope :recent, -> { order(created_at: :desc) }
    # scope :by_user, ->(user_id) { where(user_id: user_id) }
    # scope :published, -> { where(status: :published) }

    # === Callbacks (use sparingly - data normalization only) ===
    # before_validation :normalize_email
    # before_save :set_defaults

    # === Instance Methods (simple predicates/formatters only) ===
    # def full_name
    #   "#{first_name} #{last_name}"
    # end
    #
    # def published?
    #   status == 'published'
    # end

    private

    # === Private Methods ===
    # def normalize_email
    #   self.email = email.to_s.downcase.strip
    # end
    #
    # def set_defaults
    #   self.status ||= 'draft'
    # end
  end
end

# === RULES ===
# ✅ DO:
#   - Define associations
#   - Define validations
#   - Define scopes
#   - Simple predicates (published?, active?)
#   - Simple formatters (full_name)
#   - Data normalization callbacks (downcase, strip)
#
# ❌ DON'T:
#   - Complex business logic (use Operations)
#   - External API calls
#   - Email sending
#   - Callbacks with side effects
#   - Methods longer than 5-10 lines
#
# === RELATED TEMPLATES ===
# - Operation: templates/operation.rb
# - Model Spec: templates/model_spec.rb