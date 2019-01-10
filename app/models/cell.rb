# frozen_string_literal: true

class Cell < ApplicationRecord
  has_many :villages, inverse_of: :cell, dependent: :destroy
  belongs_to :sector, inverse_of: :cells

  validates_presence_of :name, :sector_id
  validates_uniqueness_of :gis_id, allow_nil: true

  def district
    sector.district
  end
end
