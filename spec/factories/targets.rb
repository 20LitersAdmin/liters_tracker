# frozen_string_literal: true

FactoryBot.define do
  factory :target do
    contract
    technology
    goal { 1 }
    people_goal { 1 }
  end
end
