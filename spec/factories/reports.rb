# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    date { '2019-01-10' }
    technology { nil }
    distributed { 1 }
    people { nil }
    checked { 1 }
    user { nil }
    sequence(:model_gid) { |n| "gid://liters-tracker/FactoryReport/#{n}" }
  end
end
