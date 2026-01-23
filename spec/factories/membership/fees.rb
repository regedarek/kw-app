# frozen_string_literal: true

FactoryBot.define do
  factory :membership_fee, class: 'Db::Membership::Fee' do
    sequence(:kw_id) { |n| 1000 + n }
    year { Date.current.year }
    cost { 150 }
    
    trait :paid do
      after(:create) do |fee|
        payment = fee.create_payment(
          dotpay_id: SecureRandom.hex(13),
          cash: false,
          state: 'unpaid'
        )
        payment.charge! # Transition to 'prepaid' state
      end
    end
    
    trait :prepaid do
      after(:create) do |fee|
        fee.create_payment(
          dotpay_id: SecureRandom.hex(13),
          cash: false,
          state: 'prepaid'
        )
      end
    end
    
    trait :unpaid do
      after(:create) do |fee|
        fee.create_payment(
          dotpay_id: SecureRandom.hex(13),
          cash: false,
          state: 'unpaid'
        )
      end
    end
    
    trait :cash do
      after(:create) do |fee|
        fee.create_payment(
          dotpay_id: SecureRandom.hex(13),
          cash: true,
          state: 'prepaid'
        )
      end
    end
    
    trait :youth_cost do
      cost { 100 }
    end
    
    trait :reduced_cost do
      cost { 75 }
    end
    
    trait :current_year do
      year { Date.current.year }
    end
    
    trait :previous_year do
      year { Date.current.year - 1 }
    end
    
    trait :next_year do
      year { Date.current.year + 1 }
    end
  end
end