# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    fname 'User'
    sequence(:lname) { |n| "McUser#{n}" }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:email) { |n| "user#{n}@email.com" }
  end

  factory :admin, class: User do
    fname 'User'
    sequence(:lname) { |n| "McUser#{n}" }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:email) { |n| "admin#{n}@email.com" }
    admin { true }
  end
end
