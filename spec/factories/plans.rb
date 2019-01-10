# frozen_string_literal: true

FactoryBot.define do
  factory :plan do
    contract { nil }
    technology { nil }
    model_gid { "MyString" }
    goal { 1 }
    people_goal { 1 }
  end
end
