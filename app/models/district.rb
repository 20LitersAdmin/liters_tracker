# frozen_string_literal: true

class District < ApplicationRecord
  include GeographyType
  include Rails.application.routes.url_helpers
  require 'csv'

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
  after_save :toggle_relations, if: -> { saved_change_to_hidden? }

  def cell
    # Report and Plan want to be able to call any geography
    nil
  end

  scope :hidden, -> { where(hidden: true) }
  scope :visible, -> { where(hidden: false) }

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

  def self.import(filepath)
    ActiveRecord::Base.logger.silence do
      @counter = 0
      @first_count = District.all.size

      CSV.foreach(filepath, headers: true) do |row|
        @counter += 1

        record = District.find_or_create_by(name: row['name'], gis_code: row['gis_code'])

        next if record.persisted?

        # use the first digit of the record's GIS code to get the parent's GIS code
        record.country = Country.where(gis_code: record.gis_code.to_s[0].to_i).first

        record.hidden = true

        next if record.save

        puts "Failed to save: #{row}; #{record}: #{record.errors.messages}"
      end
    end

    @last_count = District.all.size

    puts "#{@counter} rows processed"
    puts "#{@last_count - @first_count} records created."
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

  private

  def toggle_relations
    # apply the same visibility to all children
    sectors.update_all hidden: hidden
    cells.update_all hidden: hidden
    villages.update_all hidden: hidden

    # if the record is now hidden, stop
    return if hidden?

    # ensure all ancestors are un-hidden
    country.update_column(:hidden, false)
  end
end
