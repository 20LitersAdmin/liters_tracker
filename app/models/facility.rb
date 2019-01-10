# frozen_string_literal: true

class Facility < ApplicationRecord
  belongs_to :village, inverse_of: :facilities

  def cell
    village.cell
  end

  def sector
    cell.sector
  end

  def district
    sector.district
  end
end
