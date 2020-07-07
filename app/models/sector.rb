# frozen_string_literal: true

class Sector < ApplicationRecord
  include GeographyType
  include Rails.application.routes.url_helpers

  belongs_to :district,   inverse_of: :sectors

  has_one    :country,    through: :district, inverse_of: :sectors

  has_many   :cells,      inverse_of: :sector, dependent: :destroy
  has_many   :villages,   through: :cells,     inverse_of: :sector
  has_many   :facilities, through: :villages,  inverse_of: :sector
  has_many   :reports,    as: :reportable,     inverse_of: :reportable
  has_many   :plans,      as: :planable,       inverse_of: :planable

  validates_presence_of :name, :district_id
  validates_uniqueness_of :gis_code, allow_blank: true

  def child_class
    'Cell'
  end

  def parent
    district
  end

  def related_plans
    Plan.where(planable_type: 'Sector', planable_id: id)
        .or(Plan.where(planable_type: 'Cell', planable_id: cells.pluck(:id)))
        .or(Plan.where(planable_type: 'Village', planable_id: villages.pluck(:id)))
        .or(Plan.where(planable_type: 'Facility', planable_id: facilities.pluck(:id)))
  end

  def related_reports
    Report.where(reportable_type: 'Sector', reportable_id: id)
          .or(Report.where(reportable_type: 'Cell', reportable_id: cells.pluck(:id)))
          .or(Report.where(reportable_type: 'Village', reportable_id: villages.pluck(:id)))
          .or(Report.where(reportable_type: 'Facility', reportable_id: facilities.pluck(:id)))
  end

  def related_stories
    Story.joins(:report).where("reports.reportable_type = 'Sector' AND reports.reportable_id = ?", id)
         .or(Story.joins(:report).where("reports.reportable_type = 'Cell' AND reports.reportable_id IN (?)", cells.pluck(:id)))
         .or(Story.joins(:report).where("reports.reportable_type = 'Village' AND reports.reportable_id IN (?)", villages.pluck(:id)))
         .or(Story.joins(:report).where("reports.reportable_type = 'Facility' AND reports.reportable_id IN (?)", facilities.pluck(:id)))
  end

  def sector
    self
  end
end
