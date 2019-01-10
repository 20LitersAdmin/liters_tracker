# frozen_string_literal: true

json.extract! technology, :id, :name, :default_impact, :agreement_required, :scale, :direct_cost, :indirect_cost, :us_cost, :local_cost, :created_at, :updated_at
json.url technology_url(technology, format: :json)
