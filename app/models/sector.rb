# frozen_string_literal: true

class Sector < ApplicationRecord
  has_many :cells,      inverse_of: :sector, dependent: :destroy
  belongs_to :district, inverse_of: :sectors

  validates_presence_of :name, :district_id
  validates_uniqueness_of :gis_id, allow_nil: true
end
