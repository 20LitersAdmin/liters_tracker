# frozen_string_literal: true

class Plan < ApplicationRecord
  belongs_to :contract,   inverse_of: :plans
  belongs_to :technology, inverse_of: :plans
  belongs_to :planable, polymorphic: true

  validates_presence_of :contract_id, :technology_id, :planable_type, :planable_id, :goal

  has_many :reports, inverse_of: :plan

  # form fields for _form
  attr_accessor :district, :sector, :cell, :village, :facility

  scope :between,         ->(from, to) { joins(:contract).where('contracts.end_date >= ? AND contracts.start_date <= ?', from, to) }
  scope :current,         -> { where(contract_id: Contract.current) }
  scope :nearest_to_date, ->(date) { joins(:contract).where('contracts.end_date >= ?', date).order(:created_at) }

  scope :only_districts,  -> { where(planable_type: 'District') }
  scope :only_sectors,    -> { where(planable_type: 'Sector') }
  scope :only_cells,      -> { where(planable_type: 'Cell') }
  scope :only_villages,   -> { where(planable_type: 'Village') }
  scope :only_facilities, -> { where(planable_type: 'Facility') }

  scope :without_reports,         -> { left_outer_joins(:reports).where(reports: { id: nil }) }
  scope :with_reports_incomplete, -> { joins(:reports).group('plans.id').having('plans.goal > SUM(reports.distributed)').select('plans.*') }

  before_validation :add_error_to_geography_fields, if: -> { planable_type.blank? || planable_id.blank? }
  before_destroy :unlink_reports

  after_save :find_reports
  after_save :update_hierarchy, if: -> { saved_change_to_planable_id? || saved_change_to_planable_type? }

  def self.incomplete
    ary = []
    ary << Plan.without_reports.pluck(:id)
    ary << Plan.with_reports_incomplete.pluck(:id)
    Plan.where(id: ary.flatten)
  end

  def complete?
    return false unless reports.any?

    (goal || 0) <= (reports.sum(:distributed) || 0)
  end

  def picture
    planable_type == 'Facility' ? 'plan_facility.jpg' : 'plan_village.jpg'
  end

  def title
    by_date = date || contract.end_date

    "#{ActionController::Base.helpers.pluralize(goal, technology.name)} for #{people_goal} people by #{by_date.strftime('%m/%d/%Y')}"
  end

  # this is a terrible idea
  # def date
  #   read_attribute(:date) || contract.end_date
  # end

  def links
    "<a class='btn blue small' href='/contracts/#{contract_id}/plans/#{id}/edit'>Edit</a> <a data-confirm='Are you sure?' class='btn red small' rel='nofollow' data-method='delete' href='/contracts/#{contract_id}/reports/#{id}'>Delete</a>".html_safe
  end

  def self.related_facilities
    # return a collection of Facilities from a collection of Plans
    return Facility.none if self.only_facilities.empty?

    ary = self.only_facilities.pluck(:planable_id)
    Facility.where(id: ary)
  end

  def self.related_villages
    # return a collection of Villages from a collection of Plans
    return Village.none if self.only_facilities.empty? && self.only_villages.empty?

    ary_of_ids = self.only_villages.pluck(:planable_id)
    ary_of_ids += self.ary_of_village_ids_from_facilities if self.only_facilities.any?

    Village.all.where(id: ary_of_ids.uniq)
  end

  def self.related_cells
    # return a collection of Cells from a collection of Plans
    return Cell.none if self.only_facilities.empty? && self.only_villages.empty? && self.only_cells.empty?

    ary_of_ids = self.only_cells.pluck(:planable_id)
    ary_of_ids += self.ary_of_cell_ids_from_villages if self.only_villages.any? || self.only_facilities.any?

    Cell.all.where(id: ary_of_ids.uniq)
  end

  def self.related_sectors
    # return a collection of Sectors from a collection of Plans
    return Sector.none if self.only_facilities.empty? && self.only_villages.empty? && self.only_cells.empty? && self.only_sectors.empty?

    ary_of_ids = self.only_sectors.pluck(:planable_id)
    ary_of_ids += self.ary_of_sector_ids_from_cells if self.only_cells.any? || self.only_villages.any? || self.only_facilities.any?

    Sector.all.where(id: ary_of_ids.uniq)
  end

  def self.related_districts
    # return a collection of Districts from a collection of Plans
    return District.none if self.only_facilities.empty? && self.only_villages.empty? && self.only_cells.empty? && self.only_sectors.empty? && self.only_districts.empty?

    ary_of_ids = self.only_districts.pluck(:planable_id)
    ary_of_ids += self.ary_of_district_ids_from_sectors if self.only_sectors.any? || self.only_cells.any? || self.only_villages.any? || self.only_facilities.any?

    District.all.where(id: ary_of_ids.uniq)
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

  private

  def add_error_to_geography_fields
    errors.add(:district, ': No geography selected')
    errors.add(:sector, ': No geography selected')
    errors.add(:cell, ': No geography selected')
    errors.add(:village, ': No geography selected')
    errors.add(:facility, ': No geography selected')
  end

  def find_reports
    # edge case: reports have been created without a plan_id
    # add plan_id to these records once an applicable plan is created
    reps = Report.where(contract_id: contract_id,
                        plan_id: nil,
                        technology_id: technology_id,
                        reportable_id: planable_id,
                        reportable_type: planable_type)
    reps.update_all(plan_id: id) if reps.any?
  end

  def unlink_reports
    reports.update_all(plan_id: nil)
  end

  def update_hierarchy
    return unless planable.present?

    update_column(:hierarchy, reload.planable.hierarchy)
  end
end
