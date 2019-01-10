# frozen_string_literal: true

json.extract! sector, :id, :name, :gis_id, :latitude, :longitude, :population, :households, :created_at, :updated_at
json.url sector_url(sector, format: :json)
