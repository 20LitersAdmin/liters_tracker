# frozen_string_literal: true

FactoryBot.define do
  factory :technology_family, class: 'Technology' do
    name { "TechFamily" }
    short_name { "TF" }
    default_impact { 1 }
    scale { "Family" }
    direct_cost { "1000" }
    indirect_cost { "1500" }
    us_cost { "800" }
    local_cost { "200" }
  end

  factory :technology_community, class: 'Technology' do
    name { "TechCommunity" }
    short_name { "TC" }
    default_impact { 1 }
    scale { "Community" }
    agreement_required { true }
    direct_cost { "10000" }
    indirect_cost { "15000" }
    us_cost { "8000" }
    local_cost { "2000" }
  end
end
