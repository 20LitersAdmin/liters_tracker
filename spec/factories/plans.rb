# frozen_string_literal: true

FactoryBot.define do
  factory :plan_village, class: Plan do
    contract
    technology
    sequence(:model_gid) { |n| "gid://liters-tracker/FactoryVillage/#{n}" }
    goal { 1 }
    people_goal { 1 }
    association :planable, factory: :village
  end

  factory :plan_sector, class: Plan do
    contract
    technology
    sequence(:model_gid) { |n| "gid://liters-tracker/FactorySector/#{n}" }
    goal { 1 }
    people_goal { 1 }
    association :planable, factory: :sector
  end


end
