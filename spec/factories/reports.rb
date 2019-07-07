# frozen_string_literal: true

FactoryBot.define do
  factory :report_facility, class: Report do
    date { '2019-01-10' }
    technology
    user
    contract
    sequence(:model_gid) { |n| "gid://liters-tracker/FactoryFacility/#{n}" }
    distributed { 1 }
    checked { 1 }
    people { 1 }
    households { 1 }
    association :reportable, factory: :facility
  end

  factory :report_village, class: Report do
    date { '2019-01-10' }
    technology
    user
    contract
    sequence(:model_gid) { |n| "gid://liters-tracker/FactoryVillage/#{n}" }
    distributed { 1 }
    checked { 1 }
    people { 1 }
    households { 1 }
    association :reportable, factory: :village
  end
end
