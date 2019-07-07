# frozen_string_literal: true

class Sector < ApplicationRecord
  has_many :cells,      inverse_of: :sector, dependent: :destroy
  belongs_to :district, inverse_of: :sectors
  has_many :villages, through: :cells, inverse_of: :sector
  has_many :facilities, through: :villages, inverse_of: :sector
  has_many :reports, as: :reportable, inverse_of: :reportable

  validates_presence_of :name, :district_id
  validates_uniqueness_of :gis_id, allow_nil: true
end
