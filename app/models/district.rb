# frozen_string_literal: true

class District < ApplicationRecord
  include GeographyType
  include Rails.application.routes.url_helpers

  belongs_to :country,    inverse_of: :districts

  has_many   :sectors,    inverse_of: :district, dependent: :destroy
  has_many   :cells,      through: :sectors,     inverse_of: :district
  has_many   :villages,   through: :cells,       inverse_of: :district
  has_many   :facilities, through: :villages,    inverse_of: :district

  has_many   :reports,    as: :reportable,       inverse_of: :reportable
  has_many   :plans,      as: :planable,         inverse_of: :planable

  validates_presence_of :name
  validates_uniqueness_of :gis_code, allow_nil: true

  after_save :update_hierarchy, if: -> { saved_change_to_country_id? }

  def cell
    # Report and Plan want to be able to call any geography
    nil
  end

  def child_class
    'Sector'
  end

  def district
    self
  end

  def facility
    # Report and Plan want to be able to call any geography
    nil
  end

  def parent
    country
  end

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

  def sector
    # Report and Plan want to be able to call any geography
    nil
  end

  def update_hierarchy(cascade: false)
    update_column(:hierarchy, [{ parent_name: parent.name, parent_type: parent.class.to_s, link: country_path(country) }])

    return unless cascade || saved_change_to_country_id?

    reload.sectors.each do |s|
      s.reload.update_hierarchy(cascade: true)
    end
  end

  def village
    # Report and Plan want to be able to call any geography
    nil
  end
end
