# frozen_string_literal: true

class Facility < ApplicationRecord
  belongs_to :village, inverse_of: :facilities, dependent: :destroy

  validates_presence_of :name, :village_id
  validates :category, inclusion: { in: Constants::Facility::CATEGORY, message: "must be one of these: #{Constants::Facility::CATEGORY.to_sentence}" }

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
