# frozen_string_literal: true

FactoryBot.define do
  factory :cell do
    name { "FactoryCell" }
    sector
    latitude { 1.5 }
    longitude { 1.5 }
    population { 1 }
    households { 1 }
  end
end
