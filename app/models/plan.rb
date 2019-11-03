# frozen_string_literal: true
require 'cache/cortex.rb'

class Plan < ApplicationRecord
  belongs_to :contract,   inverse_of: :plans
  belongs_to :technology, inverse_of: :plans
  belongs_to :planable, polymorphic: true

  validates_presence_of :contract_id, :technology_id, :planable_type, :planable_id, :goal

  scope :between,         ->(from, to) { joins(:contract).where('contracts.end_date >= ? AND contracts.start_date <= ?', from, to) }
  scope :current,         -> { where(contract_id: Contract.current) }
  scope :nearest_to_date, ->(date) { joins(:contract).where('contracts.end_date >= ?', date).order(:created_at) }

  scope :only_districts,  -> { where(planable_type: 'District') }
  scope :only_sectors,    -> { where(planable_type: 'Sector') }
  scope :only_cells,      -> { where(planable_type: 'Cell') }
  scope :only_villages,   -> { where(planable_type: 'Village') }
  scope :only_facilities, -> { where(planable_type: 'Facility') }

  scope :with_reports,    -> { joins('LEFT JOIN reports ON plans.contract_id = reports.contract_id AND plans.technology_id = reports.technology_id AND plans.planable_id = reports.reportable_id AND plans.planable_type = reports.reportable_type') }

  def self.incomplete
    with_reports.having('plans.goal > SUM(reports.distributed)').group('plans.id, reports.id')
  end

  def self.related_to(record)
    where(planable_type: record.class.to_s, planable_id: record.id)
  end

  def self.related_to_facility(facility, only_ary: false)
    raise 'ERROR. Must provide a facility.' unless facility.is_a? Facility

    plans = related_to(facility)

    return plans.pluck(:id) if only_ary

    plans
  end

  def self.related_to_village(village, only_ary: false)
    raise 'ERROR. Must provide a village.' unless village.is_a? Village

    plan_ids = related_to(village).pluck(:id)
    village.facilities.each { |facility| plan_ids << related_to_facility(facility, only_ary: true) }

    return plan_ids.flatten.uniq if only_ary

    where(id: plan_ids.flatten.uniq)
  end

  def self.related_to_cell(cell, only_ary: false)
    raise 'ERROR. Must provide a cell.' unless cell.is_a? Cell

    plan_ids = related_to(cell).pluck(:id)
    cell.villages.each { |village| plan_ids << related_to_village(village, only_ary: true) }

    return plan_ids.flatten.uniq if only_ary

    where(id: plan_ids.flatten.uniq)
  end

  def self.related_to_sector(sector, only_ary: false)
    raise 'ERROR. Must provide a sector.' unless sector.is_a? Sector

    plan_ids = related_to(sector).pluck(:id)
    sector.cells.each { |cell| plan_ids << related_to_cell(cell, only_ary: true) }

    return plan_ids.flatten.uniq if only_ary

    where(id: plan_ids.flatten.uniq)
  end

  def self.related_to_district(district)
    raise 'ERROR. Must provide a district.' unless district.is_a? District

    plan_ids = related_to(district).pluck(:id)
    district.sectors.each { |sector| plan_ids << related_to_sector(sector, only_ary: true) }

    where(id: plan_ids.flatten.uniq)
  end

  def self.related_facilities
    # return a collection of Facilities from a collection of Plans
    return Facility.none if self.only_facilities.empty?

    ary = self.only_facilities.pluck(:planable_id)
    Facility.where(id: ary)
  end

  def self.related_villages
    # return a collection of Villages from a collection of Reports
    return Village.none if self.only_facilities.empty? && self.only_villages.empty?

    ary_of_ids = self.only_villages.pluck(:planable_id)
    ary_of_ids += self.ary_of_village_ids_from_facilities if self.only_facilities.any?

    Village.all.where(id: ary_of_ids.uniq)
  end

  def self.related_cells
    # return a collection of Cells from a collection of Reports
    return Cell.none if self.only_facilities.empty? && self.only_villages.empty? && self.only_cells.empty?

    ary_of_ids = self.only_cells.pluck(:planable_id)
    ary_of_ids += self.ary_of_cell_ids_from_villages if self.only_villages.any? || self.only_facilities.any?

    Cell.all.where(id: ary_of_ids.uniq)
  end

  def self.related_sectors
    # return a collection of Sectors from a collection of Reports
    return Sector.none if self.only_facilities.empty? && self.only_villages.empty? && self.only_cells.empty? && self.only_sectors.empty?

    ary_of_ids = self.only_sectors.pluck(:planable_id)
    ary_of_ids += self.ary_of_sector_ids_from_cells if self.only_cells.any? || self.only_villages.any? || self.only_facilities.any?

    Sector.all.where(id: ary_of_ids.uniq)
  end

  def self.related_districts
    # return a collection of Districts from a collection of Reports
    return District.none if self.only_facilities.empty? && self.only_villages.empty? && self.only_cells.empty? && self.only_sectors.empty? && self.only_districts.empty?

    ary_of_ids = self.only_districts.pluck(:planable_id)
    ary_of_ids += self.ary_of_district_ids_from_sectors if self.only_sectors.any? || self.only_cells.any? || self.only_villages.any? || self.only_facilities.any?

    District.all.where(id: ary_of_ids.uniq)
  end

  def date
    read_attribute(:date) || contract.end_date
  end

  def self.ary_of_village_ids_from_facilities
    related_facilities.pluck(:village_id)
  end

  def self.ary_of_cell_ids_from_villages
    related_villages.pluck(:cell_id)
  end

  def self.ary_of_sector_ids_from_cells
    related_cells.pluck(:sector_id)
  end

  def self.ary_of_district_ids_from_sectors
    related_sectors.pluck(:district_id)
  end
  
  def picture
    planable_type == 'Facility' ? 'plan_facility.jpg' : 'plan_village.jpg'
  end
  
  def reports
    Report.where(contract_id: self.contract_id,
                 technology_id: self.technology_id,
                 reportable_id: self.planable_id,
                 reportable_type: self.planable_type)
  end

  def title
    "#{goal} #{technology.name}s for #{people_goal} people by #{date.strftime('%m/%d/%Y')}"
  end

  def complete?
    (self.goal || 0) < (reports.sum(:distributed) || 0)
  end
end
