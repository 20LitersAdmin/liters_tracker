# frozen_string_literal: true

FactoryBot.define do
  factory :facility do
    name { 'FactoryFacility' }
    latitude { 1.5 }
    longitude { 1.5 }
    population { 1 }
    households { 1 }
    category { 'Church' }
    village
  end
end
