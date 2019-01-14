# frozen_string_literal: true

class Sector < ApplicationRecord
  has_many :cells,      inverse_of: :sector, dependent: :destroy
  belongs_to :district, inverse_of: :sectors
  has_many :villages, through: :cells, inverse_of: :sector
  has_many :facilities, through: :villages, inverse_of: :sector

  validates_presence_of :name, :district_id
  validates_uniqueness_of :gis_id, allow_nil: true

  # scope :active_between, ->(sdate, edate) { joins(:reports).where() }

  def active_reports_between(sdate, edate)
    # Only pulls reports for the sector, not it's decendents
    Report.related_to(self).where(date: sdate..edate)
  end

  def active_plans_between(sdate, edate)
    # Only pulls plans for the sector, not it's decendents
    Plan.between(sdate, edate).related_to(self)
  end
end
