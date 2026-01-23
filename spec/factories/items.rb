# frozen_string_literal: true

FactoryBot.define do
  factory :item, class: 'Db::Item' do
    sequence(:display_name) { |n| "Item #{n}" }
    description { Faker::Lorem.sentence }
    rentable { true }
    owner { 'kw' }
    
    trait :not_rentable do
      rentable { false }
    end
    
    trait :kw_owned do
      owner { 'kw' }
    end
    
    trait :snw_owned do
      owner { 'snw' }
    end
    
    trait :sww_owned do
      owner { 'sww' }
    end
    
    trait :instructors_owned do
      owner { 'instructors' }
    end
    
    # Legacy compatibility - matches fixture data
    factory :item_czekan do
      display_name { 'Czekan' }
      description { 'Taki tam' }
      rentable { true }
      owner { 'kw' }
    end
    
    factory :item_raki do
      display_name { 'Raki' }
      description { 'Takie tam' }
      rentable { true }
      owner { 'snw' }
    end
    
    factory :item_raki_not_rentable do
      display_name { 'Raki 2' }
      description { 'Takie tam' }
      rentable { false }
      owner { 'sww' }
    end
    
    factory :item_raki_instructors do
      display_name { 'Raki 3' }
      description { 'Takie tam' }
      rentable { true }
      owner { 'instructors' }
    end
  end
end