# frozen_string_literal: true

FactoryBot.define do
  factory :technology do
    name { "MyString" }
    default_impact { 1 }
    agreement_required { false }
    scale { "MyString" }
    direct_cost { "" }
    indirect_cost { "" }
    us_cost { "" }
    local_cost { "" }
  end
end
