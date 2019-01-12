# frozen_string_literal: true

json.extract! update, :id, :date, :technology_id, :distributed, :checked, :user_id, :model_gid, :distribute, :check, :created_at, :updated_at
json.url update_url(update, format: :json)
