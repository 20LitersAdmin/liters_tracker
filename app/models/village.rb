# frozen_string_literal: true

class Village < ApplicationRecord
  include GeographyType
  include Rails.application.routes.url_helpers
  require 'csv'

  belongs_to :cell,       inverse_of: :villages

  has_one    :sector,     through: :cell,     inverse_of: :villages
  has_one    :district,   through: :sector,   inverse_of: :villages
  has_one    :country,    through: :district, inverse_of: :villages

  has_many   :facilities, inverse_of: :village, dependent: :destroy

  has_many   :reports,    as: :reportable, inverse_of: :reportable
  has_many   :plans,      as: :planable,   inverse_of: :planable

  validates_presence_of :name, :cell_id
  validates_uniqueness_of :gis_code, allow_blank: true

  scope :hidden, -> { where(hidden: true) }
  scope :visible, -> { where(hidden: false) }

  # record was hidden, but is now visible
  after_save :toggle_relations, if: -> { saved_change_to_hidden? && !hidden? }

  def child_class
    'Facility'
  end

  def hierarchy
    cell.hierarchy << { name: "#{cell.name} Cell", link: cell_path(cell) }
  end

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      record = Village.where(row.to_hash).first_or_initialize

      next if record.persisted?

      # drop the last 2 digits off the record's GIS code to get the parent's GIS code
      code = record.gis_code.to_s[0...record.gis_code.length - 2].to_i

      record.sector = Cell.where(gis_code: code)

      logger.warn "Failed to save: #{row}; #{record}: #{record.errors.messages}" unless record.save
    end
  end

  def parent
    cell
  end

  def related_plans
    Plan.where(planable_type: 'Village', planable_id: id)
        .or(Plan.where(planable_type: 'Facility', planable_id: facilities.pluck(:id)))
  end

  def related_reports
    Report.where(reportable_type: 'Village', reportable_id: id)
          .or(Report.where(reportable_type: 'Facility', reportable_id: facilities.pluck(:id)))
  end

  def related_stories
    Story.joins(:report).where("reports.reportable_type = 'Village' AND reports.reportable_id = ?", id)
         .or(Story.joins(:report).where("reports.reportable_type = 'Facility' AND reports.reportable_id IN (?)", facilities.pluck(:id)))
  end

  def pop_hh
    pop = population.present? ? ActiveSupport::NumberHelper.number_to_delimited(population, delimiter: ',') : '-'
    hh = households.present? ? ActiveSupport::NumberHelper.number_to_delimited(households, delimiter: ',') : '-'
    "#{pop} / #{hh}"
  end

  def village
    self
  end

  private

  def toggle_relations
    # ensure all ancestors are un-hidden
    cell.update_column(:hidden, false)
    sector.update_column(:hidden, false)
    district.update_column(:hidden, false)
    country.update_column(:hidden, false)
  end
end
