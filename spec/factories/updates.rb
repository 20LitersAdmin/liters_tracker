# frozen_string_literal: true

FactoryBot.define do
  factory :update do
    date { "2019-01-10" }
    technology { nil }
    distributed { 1 }
    checked { 1 }
    user { nil }
    model_gid { "MyString" }
    distribute { 1 }
    check { 1 }
  end
end
