# frozen_string_literal: true

FactoryBot.define do
  factory :order, class: 'Db::Order' do
    association :user
    
    trait :with_payment do
      after(:create) do |order|
        create(:payment, order: order)
      end
    end
    
    trait :paid do
      after(:create) do |order|
        create(:payment, :paid, order: order)
      end
    end
    
    trait :unpaid do
      after(:create) do |order|
        create(:payment, :unpaid, order: order)
      end
    end
  end
end