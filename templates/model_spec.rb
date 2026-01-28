# frozen_string_literal: true

# Template: Model Spec
# Location: spec/models/db/{{resource}}_spec.rb
#
# Replace:
#   {{Resource}}  → PascalCase singular (e.g., User, BlogPost)
#   {{resource}}  → snake_case singular (e.g., user, blog_post)

require 'rails_helper'

RSpec.describe Db::{{Resource}}, type: :model do
  # === Factory ===
  subject(:{{resource}}) { build(:{{resource}}) }

  # === Associations ===
  describe 'associations' do
    # it { is_expected.to belong_to(:user) }
    # it { is_expected.to belong_to(:category).optional }
    # it { is_expected.to have_many(:comments).dependent(:destroy) }
    # it { is_expected.to have_one(:profile).dependent(:destroy) }
  end

  # === Validations ===
  describe 'validations' do
    # it { is_expected.to validate_presence_of(:name) }
    # it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    # it { is_expected.to validate_length_of(:name).is_at_least(2).is_at_most(100) }
    # it { is_expected.to validate_inclusion_of(:status).in_array(%w[draft published archived]) }
  end

  # === Custom Validations ===
  describe 'custom validations' do
    # describe 'end_date_after_start_date' do
    #   it 'is valid when end_date is after start_date' do
    #     {{resource}} = build(:{{resource}}, start_date: 1.day.ago, end_date: 1.day.from_now)
    #     expect({{resource}}).to be_valid
    #   end
    #
    #   it 'is invalid when end_date is before start_date' do
    #     {{resource}} = build(:{{resource}}, start_date: 1.day.from_now, end_date: 1.day.ago)
    #     expect({{resource}}).not_to be_valid
    #     expect({{resource}}.errors[:end_date]).to include('must be after start date')
    #   end
    # end
  end

  # === Enums ===
  describe 'enums' do
    # it do
    #   is_expected.to define_enum_for(:status)
    #     .with_values(draft: 0, published: 1, archived: 2)
    #     .with_prefix(:status)
    # end
  end

  # === Scopes ===
  describe 'scopes' do
    # describe '.active' do
    #   let!(:active_{{resource}}) { create(:{{resource}}, active: true) }
    #   let!(:inactive_{{resource}}) { create(:{{resource}}, active: false) }
    #
    #   it 'returns only active {{resource}}s' do
    #     expect(described_class.active).to contain_exactly(active_{{resource}})
    #   end
    # end

    # describe '.recent' do
    #   let!(:old_{{resource}}) { create(:{{resource}}, created_at: 1.week.ago) }
    #   let!(:new_{{resource}}) { create(:{{resource}}, created_at: 1.day.ago) }
    #
    #   it 'returns {{resource}}s ordered by created_at descending' do
    #     expect(described_class.recent.first).to eq(new_{{resource}})
    #   end
    # end
  end

  # === Callbacks ===
  describe 'callbacks' do
    # describe 'before_validation :normalize_email' do
    #   it 'downcases and strips email' do
    #     {{resource}} = build(:{{resource}}, email: '  TEST@EXAMPLE.COM  ')
    #     {{resource}}.valid?
    #     expect({{resource}}.email).to eq('test@example.com')
    #   end
    # end

    # describe 'after_create :enqueue_welcome_job' do
    #   it 'enqueues welcome job' do
    #     expect { create(:{{resource}}) }
    #       .to have_enqueued_job({{Resource}}WelcomeJob)
    #   end
    # end
  end

  # === Instance Methods ===
  describe 'instance methods' do
    # describe '#full_name' do
    #   it 'returns concatenated first and last name' do
    #     {{resource}} = build(:{{resource}}, first_name: 'John', last_name: 'Doe')
    #     expect({{resource}}.full_name).to eq('John Doe')
    #   end
    # end

    # describe '#published?' do
    #   it 'returns true when status is published' do
    #     {{resource}} = build(:{{resource}}, status: 'published')
    #     expect({{resource}}.published?).to be true
    #   end
    #
    #   it 'returns false when status is not published' do
    #     {{resource}} = build(:{{resource}}, status: 'draft')
    #     expect({{resource}}.published?).to be false
    #   end
    # end
  end
end

# ==============================================================================
# Factory Template (spec/factories/{{resource}}s.rb)
# ==============================================================================
#
# FactoryBot.define do
#   factory :{{resource}}, class: 'Db::{{Resource}}' do
#     name { Faker::Name.name }
#     email { Faker::Internet.unique.email }
#     status { 'draft' }
#
#     # Associations
#     # association :user
#
#     # Traits
#     trait :published do
#       status { 'published' }
#     end
#
#     trait :with_comments do
#       after(:create) do |{{resource}}|
#         create_list(:comment, 3, {{resource}}: {{resource}})
#       end
#     end
#   end
# end
# ==============================================================================

# ==============================================================================
# Testing Tips
# ==============================================================================
#
# Use `build` for validation tests (doesn't hit database):
#   {{resource}} = build(:{{resource}}, email: nil)
#   expect({{resource}}).not_to be_valid
#
# Use `create` when you need persisted records:
#   {{resource}} = create(:{{resource}})
#   expect(described_class.find({{resource}}.id)).to eq({{resource}})
#
# Use Shoulda Matchers for common validations:
#   it { is_expected.to validate_presence_of(:name) }
#   it { is_expected.to validate_uniqueness_of(:email) }
#
# Test one thing per example:
#   ✅ it 'validates presence of name' do ...
#   ✅ it 'validates uniqueness of email' do ...
#   ❌ it 'validates presence and uniqueness' do ...
# ==============================================================================