FactoryBot.define do
  factory :country do
    name { "MyString" }
    gis_code { 1 }
    latitude { 1.5 }
    longitude { 1.5 }
    population { 1 }
    households { 1 }
  end
end
