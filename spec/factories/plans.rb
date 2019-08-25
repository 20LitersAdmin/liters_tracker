# frozen_string_literal: true

FactoryBot.define do
  factory :plan_facility, class: Plan do
    contract
    association :technology, factory: :technology_family
    goal { 1 }
    people_goal { 1 }
    association :planable, factory: :facility
  end

  factory :plan_village, class: Plan do
    contract
    association :technology, factory: :technology_family
    goal { 1 }
    people_goal { 1 }
    association :planable, factory: :village
  end

  factory :plan_cell, class: Plan do
    contract
    association :technology, factory: :technology_family
    goal { 1 }
    people_goal { 1 }
    association :planable, factory: :cell
  end

  factory :plan_sector, class: Plan do
    contract
    association :technology, factory: :technology_family
    goal { 1 }
    people_goal { 1 }
    association :planable, factory: :sector
  end

  factory :plan_district, class: Plan do
    contract
    association :technology, factory: :technology_family
    goal { 1 }
    people_goal { 1 }
    association :planable, factory: :district
  end
end
