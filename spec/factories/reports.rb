# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    date { '2019-01-10' }
    technology { nil }
    distributed { 1 }
    checked { 1 }
    user { nil }
    sequence(:model_gid) { |n| "gid://liters-tracker/FactoryReport/#{n}" }
    distribute { 1 }
    check { 1 }
  end
end
