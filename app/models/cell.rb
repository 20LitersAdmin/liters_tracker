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

  after_save :update_hierarchy, if: -> { saved_change_to_sector_id? }

  def cell
    self
  end

  def cells
    # Report and Plan want to be able to call any geography
    parent&.cells
  end
  after_save :toggle_relations, if: -> { saved_change_to_hidden? }

  scope :hidden, -> { where(hidden: true) }
  scope :visible, -> { where(hidden: false) }

  def child_class
    'Village'
  end

  def districts
    # Report and Plan want to be able to call any geography
    district&.parent&.districts
  end

  def facility
    # Report and Plan want to be able to call any geography
    nil
  end

  def self.import(filepath)
    ActiveRecord::Base.logger.silence do
      @counter = 0
      @first_count = Cell.all.size

      CSV.foreach(filepath, headers: true) do |row|
        @counter += 1
        record = Cell.find_or_create_by(name: row['name'], gis_code: row['gis_code'])

        next if record.persisted?

        # drop the last 2 digits off the record's GIS code to get the parent's GIS code
        code = record.gis_code.to_s[0...record.gis_code.to_s.length - 2].to_i

        record.sector = Sector.where(gis_code: code).first
        record.hidden = true

        next if record.save

        puts "Failed to save: #{row}; #{record}: #{record.errors.messages}"
      end
    end

    @last_count = Cell.all.size

    puts "#{@counter} rows processed"
    puts "#{@last_count - @first_count} records created."
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

  def sectors
    # Report and Plan want to be able to call any geography
    sector&.parent&.sectors
  end

  def village
    # Report and Plan want to be able to call any geography
    nil
  end

  def update_hierarchy(cascade: false)
    parent_hierarchy = sector.hierarchy

    update_column(:hierarchy, parent_hierarchy << { parent_name: sector.name, parent_type: sector.class.to_s, link: sector_path(sector) })

    return unless cascade || saved_change_to_sector_id?

    reload.villages.each do |v|
      v.reload.update_hierarchy(cascade: true)
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
