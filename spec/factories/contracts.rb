# frozen_string_literal: true

FactoryBot.define do
  factory :contract do
    start_date { '2018-01-09' }
    end_date { '2019-01-09' }
    budget { '50000' }
    household_goal { 1 }
    people_goal { 1 }
  end
end
