# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :technology, inverse_of: :reports
  belongs_to :user,       inverse_of: :reports
  belongs_to :contract,   inverse_of: :reports
  serialize :model_gid

  scope :only_districts,  -> { where('model_gid ILIKE ?', '%/District/%') }
  scope :only_sectors,    -> { where('model_gid ILIKE ?', '%/Sector/%') }
  scope :only_cells,      -> { where('model_gid ILIKE ?', '%/Cell/%') }
  scope :only_villages,   -> { where('model_gid ILIKE ?', '%/Village/%') }
  scope :only_facilities, -> { where('model_gid ILIKE ?', '%/Facility/%') }

  def model
    GlobalID::Locator.locate model_gid
  end

  def self.earliest_date
    self.all.order(date: :asc).first.date
  end

  def self.latest_date
    self.all.order(date: :asc).last.date
  end

  def self.related_to(record)
    where(model_gid: record.to_global_id.to_s)
  end

  def self.related_to_sector(sector, only_ary: false)
    report_ids = []
    report_ids << related_to(sector).pluck(:id)
    sector.cells.each { |cell| report_ids << related_to(cell).pluck(:id) }
    sector.villages.each { |village| report_ids << related_to(village).pluck(:id) }
    sector.facilities.each { |facility| report_ids << related_to(facility).pluck(:id) }

    return report_ids.flatten! if only_ary

    where(id: report_ids.flatten!)
  end

  def self.related_to_district(district)
    report_ids = []
    report_ids << related_to(district).pluck(:id)
    district.sectors.each { |sector| report_ids << Report.related_to_sector(sector, only_ary: true) }

    where(id: report_ids.flatten!)
  end

  def people_served
    model_gid.include?('Facility') && model.impact.positive? ? model.impact : (technology.default_impact * distributed.to_i)
  end
end
