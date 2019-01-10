# frozen_string_literal: true

json.extract! plan, :id, :contract_id, :technology_id, :model_gid, :goal, :people_goal, :created_at, :updated_at
json.url plan_url(plan, format: :json)
