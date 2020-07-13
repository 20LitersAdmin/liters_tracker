# frozen_string_literal: true

class Country < ApplicationRecord
  include GeographyType

  has_many :districts,  inverse_of: :country
  has_many :sectors,    through: :districts, inverse_of: :country
  has_many :cells,      through: :sectors,   inverse_of: :country
  has_many :villages,   through: :cells,     inverse_of: :country
  has_many :facilities, through: :villages,  inverse_of: :country
  has_many :reports,    as: :reportable,     inverse_of: :reportable
  has_many :plans,      as: :planable,       inverse_of: :planable

  validates_presence_of :name
  validates_uniqueness_of :gis_code, allow_nil: true

  scope :hidden, -> { where(hidden: true) }
  scope :visible, -> { where(hidden: false) }

  def child_class
    'District'
  end

  def country
    # see config/initializers/geography_type.rb
    self
  end

  def hierarchy
    []
  end

  def related_plans
    Plan.where(planable_type: 'Country', planable_id: id)
        .or(Plan.where(planable_type: 'District', planable_id: districts.pluck(:id)))
        .or(Plan.where(planable_type: 'Sector', planable_id: sectors.pluck(:id)))
        .or(Plan.where(planable_type: 'Cell', planable_id: cells.pluck(:id)))
        .or(Plan.where(planable_type: 'Village', planable_id: villages.pluck(:id)))
        .or(Plan.where(planable_type: 'Facility', planable_id: facilities.pluck(:id)))
  end

  def related_reports
    Report.where(reportable_type: 'Country', reportable_id: id)
          .or(Report.where(reportable_type: 'District', reportable_id: districts.pluck(:id)))
          .or(Report.where(reportable_type: 'Sector', reportable_id: sectors.pluck(:id)))
          .or(Report.where(reportable_type: 'Cell', reportable_id: cells.pluck(:id)))
          .or(Report.where(reportable_type: 'Village', reportable_id: villages.pluck(:id)))
          .or(Report.where(reportable_type: 'Facility', reportable_id: facilities.pluck(:id)))
  end

  def related_stories
    Story.joins(:report).where("reports.reportable_type = 'Country' AND reports.reportable_id = ?", id)
         .or(Story.joins(:report).where("reports.reportable_type = 'District' AND reports.reportable_id IN (?)", districts.pluck(:id)))
         .or(Story.joins(:report).where("reports.reportable_type = 'Sector' AND reports.reportable_id IN (?)", sectors.pluck(:id)))
         .or(Story.joins(:report).where("reports.reportable_type = 'Cell' AND reports.reportable_id IN (?)", cells.pluck(:id)))
         .or(Story.joins(:report).where("reports.reportable_type = 'Village' AND reports.reportable_id IN (?)", villages.pluck(:id)))
         .or(Story.joins(:report).where("reports.reportable_type = 'Facility' AND reports.reportable_id IN (?)", facilities.pluck(:id)))
  end
end
