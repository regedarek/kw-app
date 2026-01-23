# frozen_string_literal: true

FactoryBot.define do
  factory :reservation, class: 'Db::Reservation' do
    association :user
    
    start_date { '2016-08-18' }
    end_date { '2016-08-25' }
    state { 'reserved' }
    remarks { 'Test reservation' }
    
    trait :with_items do
      transient do
        items_count { 1 }
      end
      
      after(:create) do |reservation, evaluator|
        create_list(:item, evaluator.items_count).each do |item|
          reservation.items << item
        end
      end
    end
    
    trait :with_specific_item do
      transient do
        item { nil }
      end
      
      after(:create) do |reservation, evaluator|
        reservation.items << evaluator.item if evaluator.item
      end
    end
    
    trait :cancelled do
      state { 'cancelled' }
    end
    
    trait :completed do
      state { 'completed' }
    end
    
    trait :current_week do
      start_date { Date.current.beginning_of_week(:thursday) }
      end_date { Date.current.beginning_of_week(:thursday) + 7.days }
    end
    
    trait :next_week do
      start_date { Date.current.beginning_of_week(:thursday) + 7.days }
      end_date { Date.current.beginning_of_week(:thursday) + 14.days }
    end
  end
  
  # Form object factory (for Reservations::Form tests)
  factory :reservation_form, class: 'Reservations::Form' do
    skip_create
    
    start_date { '2016-08-18' }
    end_date { '2016-08-25' }
    item_ids { [1] }
    
    initialize_with { new(attributes) }
    
    trait :current_week do
      start_date { Date.current.beginning_of_week(:thursday).to_s }
      end_date { (Date.current.beginning_of_week(:thursday) + 7.days).to_s }
    end
    
    trait :next_week do
      start_date { (Date.current.beginning_of_week(:thursday) + 7.days).to_s }
      end_date { (Date.current.beginning_of_week(:thursday) + 14.days).to_s }
    end
  end
end