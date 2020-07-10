# frozen_string_literal: true

class Cell < ApplicationRecord
  include GeographyType
  include Rails.application.routes.url_helpers
  require 'csv'

  belongs_to :sector,     inverse_of: :cells

  has_one    :district,   through: :sector,   inverse_of: :cells
  has_one    :country,    through: :district, inverse_of: :cells

  has_many   :villages,   inverse_of: :cell
  has_many   :facilities, through: :villages, inverse_of: :cell

  has_many   :reports,    as: :reportable,    inverse_of: :reportable
  has_many   :plans,      as: :planable,      inverse_of: :planable

  validates_presence_of :name, :sector_id
  validates_uniqueness_of :gis_code, allow_blank: true

  after_save :toggle_relations, if: -> { saved_change_to_hidden? }

  scope :hidden, -> { where(hidden: true) }
  scope :visible, -> { where(hidden: false) }

  def child_class
    'Village'
  end

  def hierarchy
    sector.hierarchy << { name: "#{sector.name} Sector", link: sector_path(sector) }
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      record = Cell.where(row.to_hash).first_or_initialize

      next if record.persisted?

      # drop the last 2 digits off the record's GIS code to get the parent's GIS code
      code = record.gis_code.to_s[0...record.gis_code.length - 2].to_i

      record.sector = Sector.where(gis_code: code)

      logger.warn "Failed to save: #{row}; #{record}: #{record.errors.messages}" unless record.save
    end
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

  private

  def toggle_relations
    villages.update_all hidden: hidden

    # if the record is now hidden, stop
    return if hidden?

    # ensure all ancestors are un-hidden
    sector.update_column(:hidden, false)
    district.update_column(:hidden, false)
    country.update_column(:hidden, false)
  end
end
