# frozen_string_literal: true

FactoryBot.define do
  factory :payment, class: 'Db::Payment' do
    dotpay_id { SecureRandom.hex(13) }
    cash { false }
    state { 'unpaid' }
    
    trait :cash do
      cash { true }
    end
    
    trait :unpaid do
      state { 'unpaid' }
    end
    
    trait :prepaid do
      state { 'prepaid' }
    end
    
    trait :paid do
      state { 'paid' }
    end
    
    trait :cancelled do
      state { 'cancelled' }
    end
  end
end