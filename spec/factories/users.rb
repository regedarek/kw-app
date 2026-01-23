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