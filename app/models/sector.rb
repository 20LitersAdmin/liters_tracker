# frozen_string_literal: true

class Sector < ApplicationRecord
  include GeographyType
  include Rails.application.routes.url_helpers
  require 'csv'

  belongs_to :district,   inverse_of: :sectors

  has_one    :country,    through: :district, inverse_of: :sectors

  has_many   :cells,      inverse_of: :sector, dependent: :destroy
  has_many   :villages,   through: :cells,     inverse_of: :sector
  has_many   :facilities, through: :villages,  inverse_of: :sector
  has_many   :reports,    as: :reportable,     inverse_of: :reportable
  has_many   :plans,      as: :planable,       inverse_of: :planable

  validates_presence_of :name, :district_id
  validates_uniqueness_of :gis_code, allow_blank: true

  after_save :update_hierarchy, if: -> { saved_change_to_district_id? }
  after_save :toggle_relations, if: -> { saved_change_to_hidden? }

  scope :hidden, -> { where(hidden: true) }
  scope :visible, -> { where(hidden: false) }

  def cell
    # Report and Plan want to be able to call any geography
    nil
  end

  def child_class
    'Cell'
  end

  def descendants
    {
      'cell': cells.select(:id, :name).order(:name),
      'village': villages.select(:id, :name).order(:name),
      'facility': facilities.select(:id, :name).order(:name)
    }.to_json
  end

  def districts
    # Report and Plan want to be able to call any geography
    district&.parent&.districts
  end

  def self.import(filepath)
    ActiveRecord::Base.logger.silence do
      @counter = 0
      @first_count = Sector.all.size

      CSV.foreach(filepath, headers: true) do |row|
        @counter += 1
        record = Sector.find_or_create_by(name: row['name'], gis_code: row['gis_code'])

        next if record.persisted?

        # drop the last 2 digits off the record's GIS code to get the parent's GIS code
        code = record.gis_code.to_s[0...record.gis_code.to_s.length - 2].to_i

        record.district = District.where(gis_code: code).first
        record.hidden = true

        next if record.save

        puts "Failed to save: #{row}; #{record}: #{record.errors.messages}"
      end
    end

    @last_count = Sector.all.size

    puts "#{@counter} rows processed"
    puts "#{@last_count - @first_count} records created."
  end

  def parent
    district
  end

  def facility
    # Report and Plan want to be able to call any geography
    nil
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

  def sectors
    # Report and Plan want to be able to call any geography
    parent&.sectors
  end

  def village
    # Report and Plan want to be able to call any geography
    nil
  end

  def update_hierarchy(cascade: false)
    update_column(:hierarchy, district.hierarchy << { parent_name: district.name, parent_type: district.class.to_s, link: district_path(district) })

    return unless cascade || saved_change_to_district_id?

    reload.cells.each do |c|
      c.reload.update_hierarchy(cascade: true)
    end
  end

  private

  def toggle_relations
    cells.update_all hidden: hidden
    villages.update_all hidden: hidden

    # if the record is now hidden, stop
    return if hidden?

    # ensure all ancestors are un-hidden
    district.update_column(:hidden, false)
    country.update_column(:hidden, false)
  end
end
