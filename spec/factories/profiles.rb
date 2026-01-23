# frozen_string_literal: true

FactoryBot.define do
  factory :profile, class: 'Db::Profile' do
    association :user
    
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    birth_date { Faker::Date.birthday(min_age: 18, max_age: 65) }
    birth_place { Faker::Address.city }
    city { Faker::Address.city }
    postal_code { Faker::Address.zip_code }
    main_address { Faker::Address.street_address }
    optional_address { '' }
    recommended_by { ['poster'] }
    acomplished_courses { ['basic'] }
    main_discussion_group { true }
    sections { ['sww'] }
    
    trait :youth do
      birth_date { 18.years.ago }
    end
    
    trait :retired do
      positions { ['retired'] }
    end
    
    trait :with_basic_kw do
      acomplished_courses { ['basic_kw'] }
    end
    
    trait :with_cave_kw do
      acomplished_courses { ['cave_kw'] }
    end
    
    trait :with_instructors do
      acomplished_courses { ['basic', 'instructors'] }
    end
    
    trait :with_other_club do
      acomplished_courses { ['basic', 'other_club'] }
    end
    
    trait :with_list do
      acomplished_courses { ['basic', 'list'] }
    end
    
    # Legacy compatibility - matches fixture data
    factory :profile_darek do
      first_name { 'Darek' }
      last_name { 'Finster' }
      email { 'darek.finster@gmail.com' }
      phone { '777777777' }
      birth_date { '1986-12-13' }
      birth_place { 'Poznan' }
      city { 'Berlin' }
      postal_code { '31-634' }
      main_address { 'warzywna' }
      optional_address { '' }
      recommended_by { ['poster', 'facebook'] }
      acomplished_courses { ['basic'] }
      main_discussion_group { true }
      sections { ['sww'] }
    end
  end
  
  # Form object factory (for ProfileForm tests)
  factory :profile_form, class: 'UserManagement::ProfileForm' do
    skip_create
    
    first_name { 'John' }
    last_name { 'Doe' }
    email { Faker::Internet.email }
    phone { '123456789' }
    birth_date { '1990-01-01' }
    birth_place { 'Warsaw' }
    gender { 'male' }
    city { 'Krakow' }
    postal_code { '31-000' }
    main_address { 'Main St 1' }
    optional_address { '' }
    recommended_by { ['poster'] }
    acomplished_courses { ['basic'] }
    main_discussion_group { true }
    sections { ['sww'] }
    terms_of_service { true }
    
    initialize_with { new(attributes) }
    
    trait :youth do
      birth_date { 18.years.ago.to_date.to_s }
    end
    
    trait :retired do
      positions { ['retired'] }
    end
  end
end