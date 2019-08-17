# frozen_string_literal: true

FactoryBot.define do
  factory :technology do
    name { "MyString" }
    short_name { "MS" }
    default_impact { 1 }
    report_worthy { true }
    agreement_required { false }
    scale { "Family" }
    direct_cost_cents { 10000000 }
    direct_cost_currency { "USD" }
    indirect_cost_cents { 200000 }
    indirect_cost_currency { "USD" }
    us_cost_cents { 0 }
    us_cost_currency { "USD" }
    local_cost_cents { 0 }
    local_cost_currency { "USD" }
    created_at { "" }
    updated_at { "" }
  end
end
