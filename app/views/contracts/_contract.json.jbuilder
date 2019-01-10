# frozen_string_literal: true

json.extract! contract, :id, :start_date, :end_date, :budget, :household_goal, :people_goal, :created_at, :updated_at
json.url contract_url(contract, format: :json)
