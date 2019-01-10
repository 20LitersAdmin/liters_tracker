# frozen_string_literal: true

json.extract! target, :id, :contract_id, :technology_id, :goal, :people_goal, :created_at, :updated_at
json.url target_url(target, format: :json)
