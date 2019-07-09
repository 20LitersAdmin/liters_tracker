# frozen_string_literal: true

FactoryBot.define do
  factory :target do
    contract
    association :technology, factory: :technology_family
    goal { 1 }
    people_goal { 1 }
  end
end
