# frozen_string_literal: true

json.extract! district, :id, :name, :gis_id, :latitude, :longitude, :population, :households, :created_at, :updated_at
json.url district_url(district, format: :json)
