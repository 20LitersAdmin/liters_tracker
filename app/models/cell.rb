# frozen_string_literal: true

class Cell < ApplicationRecord
  include GeographyType
  include Rails.application.routes.url_helpers

  belongs_to :sector,     inverse_of: :cells

  has_one    :district,   through: :sector,   inverse_of: :cells
  has_one    :country,    through: :district, inverse_of: :cells

  has_many   :villages,   inverse_of: :cell
  has_many   :facilities, through: :villages, inverse_of: :cell

  has_many   :reports,    as: :reportable,    inverse_of: :reportable
  has_many   :plans,      as: :planable,      inverse_of: :planable

  validates_presence_of :name, :sector_id
  validates_uniqueness_of :gis_code, allow_blank: true

  after_save :update_hierarchy, if: -> { saved_change_to_sector_id? }

  def child_class
    'Village'
  end

  def parent
    sector
  end

  def related_plans
    Plan.where(planable_type: 'Cell', planable_id: id)
        .or(Plan.where(planable_type: 'Village', planable_id: villages.pluck(:id)))
        .or(Plan.where(planable_type: 'Facility', planable_id: facilities.pluck(:id)))
  end

  def related_reports
    Report.where(reportable_type: 'Cell', reportable_id: id)
          .or(Report.where(reportable_type: 'Village', reportable_id: villages.pluck(:id)))
          .or(Report.where(reportable_type: 'Facility', reportable_id: facilities.pluck(:id)))
  end

  def related_stories
    Story.joins(:report).where("reports.reportable_type = 'Cell' AND reports.reportable_id = ?", id)
         .or(Story.joins(:report).where("reports.reportable_type = 'Village' AND reports.reportable_id IN (?)", villages.pluck(:id)))
         .or(Story.joins(:report).where("reports.reportable_type = 'Facility' AND reports.reportable_id IN (?)", facilities.pluck(:id)))
  end

  def cell
    self
  end

  def village
    # some views assume all reports are at the village level
    nil
  end

  def update_hierarchy(cascade: false)
    parent_hierarchy = sector.hierarchy

    update_column(:hierarchy, parent_hierarchy << { parent_name: sector.name, parent_type: sector.class.to_s, link: sector_path(sector) })

    return unless cascade || saved_change_to_sector_id?

    reload.villages.each do |v|
      v.reload.update_hierarchy(cascade: true)
    end
  end
end
