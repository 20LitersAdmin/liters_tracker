# frozen_string_literal: true

FactoryBot.define do
  factory :user_viewer, class: User do
    fname { 'Viewer' }
    sequence(:lname) { |n| "McUser#{n}" }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:email) { |n| "viewer#{n + Time.now.usec}@email.com" }
  end

  factory :user_admin, class: User do
    fname { 'Admin' }
    sequence(:lname) { |n| "McUser#{n}" }
    admin { true }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:email) { |n| "admin#{n + Time.now.usec}@email.com" }
  end

  factory :user_reports, class: User do
    fname { 'Reporter' }
    sequence(:lname) { |n| "McUser#{n}" }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:email) { |n| "reporter#{n + Time.now.usec}@email.com" }
    can_manage_reports { true }
  end

  factory :user_geography, class: User do
    fname { 'Geographer' }
    sequence(:lname) { |n| "McUser#{n}" }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:email) { |n| "geographer#{n + Time.now.usec}@email.com" }
    can_manage_geography { true }
  end

  factory :user_contracts, class: User do
    fname { 'Contractor' }
    sequence(:lname) { |n| "McUser#{n}" }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:email) { |n| "contractor#{n + Time.now.usec}@email.com" }
    can_manage_contracts { true }
  end

  factory :user_technology, class: User do
    fname { 'Technologist' }
    sequence(:lname) { |n| "McUser#{n}" }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:email) { |n| "technologist#{n + Time.now.usec}@email.com" }
    can_manage_technologies { true }
  end
end
