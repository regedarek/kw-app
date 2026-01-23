# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: 'Db::User' do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:kw_id) { |n| 1000 + n }
    
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }
    password { 'password123' }
    encrypted_password { Devise::Encryptor.digest(Db::User, 'password123') }
    warnings { 0 }
    admin { false }
    
    trait :admin do
      admin { true }
      roles { ['admin'] }
      first_name { 'Admin' }
      last_name { 'User' }
    end
    
    trait :with_warnings do
      warnings { 3 }
    end
    
    trait :with_profile do
      after(:create) do |user|
        create(:profile, user: user)
      end
    end
    
    trait :with_membership do
      after(:create) do |user|
        create(:membership_fee, :paid, kw_id: user.kw_id, year: Date.current.year)
      end
    end
    
    # Role-based traits
    trait :with_office_role do
      roles { ['office'] }
    end
    
    trait :with_reservations_role do
      roles { ['reservations'] }
    end
    
    trait :with_events_role do
      roles { ['events'] }
    end
    
    trait :with_training_contracts_role do
      roles { ['training_contracts'] }
    end
    
    trait :with_management_role do
      roles { ['management'] }
    end
    
    trait :with_secondary_management_role do
      roles { ['secondary_management'] }
    end
    
    trait :with_financial_management_role do
      roles { ['financial_management'] }
    end
    
    trait :with_marketing_role do
      roles { ['marketing'] }
    end
    
    trait :with_projects_role do
      roles { ['projects'] }
    end
    
    trait :with_library_role do
      roles { ['library'] }
    end
    
    trait :with_voting_role do
      roles { ['voting'] }
    end
    
    trait :with_business_courses_role do
      roles { ['business_courses'] }
    end
    
    trait :with_competitions_role do
      roles { ['competitions'] }
    end
    
    # Helper to add multiple roles
    transient do
      with_roles { [] }
    end
    
    after(:build) do |user, evaluator|
      if evaluator.with_roles.any?
        user.roles = evaluator.with_roles.map(&:to_s)
      end
    end
    
    # Legacy compatibility - matches fixture data
    factory :user_darek do
      first_name { 'Darek' }
      last_name { 'Finster' }
      email { 'darek.finster@gmail.com' }
      kw_id { 1234 }
      admin { true }
    end
    
    factory :user_tomek do
      first_name { 'Tomek' }
      last_name { 'Owerko' }
      email { 'tomek.owerko@gmail.com' }
      kw_id { 2345 }
      admin { false }
    end
  end
end