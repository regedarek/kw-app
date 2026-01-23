# frozen_string_literal: true

FactoryBot.define do
  factory :mountain_route, class: 'Db::Activities::MountainRoute' do
    association :user
    
    sequence(:name) { |n| "Route #{n}" }
    climbing_date { Date.current - rand(1..30).days }
    rating { rand(1..5) }
    description { Faker::Lorem.paragraph }
    peak { 'Test Peak' }
    area { 'Test Area' }
    mountains { 'Test Mountains' }
    length { rand(100..5000) }
    time { "#{rand(1..12)}h #{rand(0..59)}min" }
    hidden { false }
    training { false }
    route_type { :regular_climbing }
    
    trait :ski do
      route_type { :ski }
      name { 'Ski Route' }
    end
    
    trait :sport_climbing do
      route_type { :sport_climbing }
      climb_style { :RP }
      difficulty { '6a' }
    end
    
    trait :trad_climbing do
      route_type { :trad_climbing }
      climb_style { :OS }
      difficulty { 'V+' }
      kurtyka_difficulty { :'V+' }
    end
    
    trait :training do
      training { true }
      route_type { :ski }
      length { 2000 }
      boar_length { 1000 }
    end
    
    trait :hidden do
      hidden { true }
    end
    
    trait :with_colleagues do
      after(:create) do |route|
        create_list(:user, 2).each do |colleague|
          route.colleagues << colleague
        end
      end
    end
    
    trait :with_photos do
      after(:create) do |route|
        create_list(:upload, 2, uploadable: route)
      end
    end
    
    trait :with_gps_track do
      map_summary_polyline { 'encodedPolylineString' }
    end
    
    trait :recent do
      climbing_date { Date.current - 1.day }
    end
    
    trait :old do
      climbing_date { 1.year.ago }
    end
  end
end