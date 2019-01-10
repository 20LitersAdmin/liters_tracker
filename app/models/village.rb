# frozen_string_literal: true

class Village < ApplicationRecord
  belongs_to :cell,     inverse_of: :villages
  has_many :facilities, inverse_of: :village

  validates_presence_of :name, :cell_id
  validates_uniqueness_of :gis_id, allow_nil: true

  def sector
    cell.sector
  end

  def district
    sector.district
  end
end
