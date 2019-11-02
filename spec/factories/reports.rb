# frozen_string_literal: true

FactoryBot.define do
  factory :report_facility, class: Report do
    date { '2019-01-10' }
    association :technology, factory: :technology_family
    association :user, factory: :user_reports
    contract
    distributed { 1 }
    people { nil }
    checked { 1 }
    association :reportable, factory: :facility
  end

  factory :report_village, class: Report do
    date { '2019-01-10' }
    association :technology, factory: :technology_family
    association :user, factory: :user_reports
    contract
    distributed { 1 }
    checked { 1 }
    people { 1 }
    association :reportable, factory: :village
  end

  factory :report_cell, class: Report do
    date { '2019-01-10' }
    association :technology, factory: :technology_family
    association :user, factory: :user_reports
    contract
    distributed { 1 }
    checked { 1 }
    people { 1 }
    association :reportable, factory: :cell
  end

  factory :report_sector, class: Report do
    date { '2019-01-10' }
    association :technology, factory: :technology_family
    association :user, factory: :user_reports
    contract
    distributed { 1 }
    checked { 1 }
    people { 1 }
    association :reportable, factory: :sector
  end

  factory :report_district, class: Report do
    date { '2019-01-10' }
    association :technology, factory: :technology_family
    association :user, factory: :user_reports
    contract
    distributed { 1 }
    checked { 1 }
    people { 1 }
    association :reportable, factory: :district
  end
end
