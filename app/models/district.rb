# frozen_string_literal: true

class District < ApplicationRecord
  include GeographyType

  belongs_to :country,    inverse_of: :districts

  has_many   :sectors,    inverse_of: :district, dependent: :destroy
  has_many   :cells,      through: :sectors,     inverse_of: :district
  has_many   :villages,   through: :cells,       inverse_of: :district
  has_many   :facilities, through: :villages,    inverse_of: :district

  has_many   :reports,    as: :reportable,       inverse_of: :reportable
  has_many   :plans,      as: :planable,         inverse_of: :planable

  validates_presence_of :name, :country_id
  validates_uniqueness_of :gis_code, allow_nil: true

  def related_plans
    Plan.where(planable_type: 'District', planable_id: id)
        .or(Plan.where(planable_type: 'Sector', planable_id: sectors.pluck(:id)))
        .or(Plan.where(planable_type: 'Cell', planable_id: cells.pluck(:id)))
        .or(Plan.where(planable_type: 'Village', planable_id: villages.pluck(:id)))
        .or(Plan.where(planable_type: 'Facility', planable_id: facilities.pluck(:id)))
  end

  def related_reports
    Report.where(reportable_type: 'District', reportable_id: id)
          .or(Report.where(reportable_type: 'Sector', reportable_id: sectors.pluck(:id)))
          .or(Report.where(reportable_type: 'Cell', reportable_id: cells.pluck(:id)))
          .or(Report.where(reportable_type: 'Village', reportable_id: villages.pluck(:id)))
          .or(Report.where(reportable_type: 'Facility', reportable_id: facilities.pluck(:id)))
  end

  def related_stories
    Story.joins(:report).where("reports.reportable_type = 'District' AND reports.reportable_id = ?", id)
         .or(Story.joins(:report).where("reports.reportable_type = 'Sector' AND reports.reportable_id IN (?)", sectors.pluck(:id)))
         .or(Story.joins(:report).where("reports.reportable_type = 'Cell' AND reports.reportable_id IN (?)", cells.pluck(:id)))
         .or(Story.joins(:report).where("reports.reportable_type = 'Village' AND reports.reportable_id IN (?)", villages.pluck(:id)))
         .or(Story.joins(:report).where("reports.reportable_type = 'Facility' AND reports.reportable_id IN (?)", facilities.pluck(:id)))
  end
end
