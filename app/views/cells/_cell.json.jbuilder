# frozen_string_literal: true

json.extract! cell, :id, :name, :gis_id, :latitude, :longitude, :population, :households, :created_at, :updated_at
json.url cell_url(cell, format: :json)
