# frozen_string_literal: true

class Facility < ApplicationRecord
  belongs_to :village, inverse_of: :facilities, dependent: :destroy
  has_one :cell, through: :village, inverse_of: :facilities
  has_one :sector, through: :cell, inverse_of: :facilities
  has_one :district, through: :sector, inverse_of: :facilities

  validates_presence_of :name, :village_id
  validates :category, inclusion: { in: Constants::Facility::CATEGORY, message: "must be one of these: #{Constants::Facility::CATEGORY.to_sentence}" }

  scope :churches, -> { where(category: 'Church') }
  scope :not_churches, -> { where.not(category: 'Church') }

  def cell
    village.cell
  end

  def sector
    cell.sector
  end

  def district
    sector.district
  end

  def current_plan
    Plan.where(contract_id: Constants::Contract::CURRENT).where(model_gid: "gid://liters-tracker/Facility/#{id}").last
  end

  def related_reports
    Report.where(model_gid: "gid://liters-tracker/Facility/#{id}")
  end
end
