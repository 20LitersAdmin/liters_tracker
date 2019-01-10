# frozen_string_literal: true

class District < ApplicationRecord
  has_many :sectors, inverse_of: :district, dependent: :destroy

  validates_presence_of :name
  validates_uniqueness_of :gis_id, allow_nil: true
end
