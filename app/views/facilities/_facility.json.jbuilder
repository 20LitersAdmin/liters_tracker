# frozen_string_literal: true

json.extract! facility, :id, :name, :gis_id, :latitude, :longitude, :population, :households, :category, :created_at, :updated_at
json.url facility_url(facility, format: :json)
