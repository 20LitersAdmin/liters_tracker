# frozen_string_literal: true

json.extract! village, :id, :name, :gis_id, :latitude, :longitude, :population, :households, :created_at, :updated_at
json.url village_url(village, format: :json)
