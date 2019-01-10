# frozen_string_literal: true

class Village < ApplicationRecord
  belongs_to :cell, inverse_of: :villages
  has_many :facilities, inverse_of: :village

  def sector
    cell.sector
  end

  def district
    sector.district
  end
end
