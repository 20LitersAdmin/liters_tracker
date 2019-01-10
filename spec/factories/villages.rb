# frozen_string_literal: true

FactoryBot.define do
  factory :village do
    name { "MyString" }
    gis_id { 1 }
    latitude { 1.5 }
    longitude { 1.5 }
    population { 1 }
    households { 1 }
  end
end
