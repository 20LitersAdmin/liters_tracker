# frozen_string_literal: true

class Report < ApplicationRecord
  include Rails.application.routes.url_helpers

  belongs_to :technology, inverse_of: :reports
  belongs_to :user,       inverse_of: :reports
  belongs_to :contract,   inverse_of: :reports, optional: true
  belongs_to :reportable, polymorphic: true
  has_one    :story, inverse_of: :report, dependent: :destroy

  belongs_to :plan, inverse_of: :reports, required: false

  validates_presence_of :date, :year, :month

  # form fields for simple_form
  attr_accessor :sector, :cell, :village, :facility

  scope :only_districts,  -> { where(reportable_type: 'District') }
  scope :only_sectors,    -> { where(reportable_type: 'Sector') }
  scope :only_cells,      -> { where(reportable_type: 'Cell') }
  scope :only_villages,   -> { where(reportable_type: 'Village') }
  scope :only_facilities, -> { where(reportable_type: 'Facility') }

  scope :within_month,    ->(date) { where(date: date.beginning_of_month..date.end_of_month) }
  scope :earliest_date,   -> { order(date: :asc)&.first&.date }
  scope :latest_date,     -> { order(date: :asc)&.last&.date }
  # even though this is simple, it matches Plan.between(), so it's nice to have.
  scope :between,         ->(from, to) { where(date: from..to).order(date: :desc) }

  # currently unused
  # scope :with_plans,      -> { joins('LEFT JOIN plans ON reports.contract_id = plans.contract_id AND reports.technology_id = plans.technology_id AND reports.reportable_id = plans.planable_id AND reports.reportable_type = plans.planable_type') }
  scope :with_stories,    -> { joins(:story).where.not(stories: { id: nil }) }
  scope :with_hours,      -> { where('hours > 0.0') }

  scope :distributions,   -> { where.not(distributed: nil) }
  scope :checks,          -> { where.not(checked: nil) }

  before_validation :set_year_and_month_from_date,  if: -> { (year.blank? || month.blank?) && date.present? }
  before_validation :set_date_from_year_and_month,  if: -> { date.blank? && year.present? && month.present? }
  before_validation :flag_for_meaninglessness,      if: -> { hours.zero? && (distributed.nil? || distributed.zero?) && (checked.nil? || checked.zero?) }

  before_save :calculate_impact
  before_save :set_contract_from_date, if: -> { contract_id.blank? && date.present? }
  before_save :set_plan,               if: -> { contract_id.present? && plan_id.blank? }

  before_update :set_year_and_month_from_date, if: -> { date.present? && date_changed? }
  before_update :set_date_from_year_and_month, if: -> { year.present? && month.present? && (year_changed? || month_changed?) }

  after_save :update_hierarchy, if: -> { saved_change_to_reportable_id? || saved_change_to_reportable_type? }

  def details
    if distributed&.positive?
      val = distributed
      lang = 'distributed'
    else
      val = checked
      lang = 'checked'
    end

    if technology.scale == 'Family'
      "#{ActionController::Base.helpers.pluralize(val, technology.name)} #{lang} during #{date.strftime('%B, %Y')}"
    else
      "#{ActionController::Base.helpers.pluralize(val, technology.name)} installed on #{date.strftime('%B, %d, %Y')}"
    end
  end

  def links
    "<a class='btn yellow small' href='/reports/#{id}/edit'>Edit</a><br /><a data-confirm='Are you sure?' class='btn red small' rel='nofollow' data-method='delete' href='/reports/#{id}'>Delete</a>".html_safe
  end

  def location
    "#{reportable.name} #{reportable.class}"
  end

  def sector_name
    reportable&.sector&.name || ''
  end

  def self.related_facilities
    # return a collection of Facilities from a collection of Reports
    return Facility.none if only_facilities.empty?

    ary = only_facilities.pluck(:reportable_id)
    Facility.all.where(id: ary)
  end

  def self.related_villages
    # return a collection of Villages from a collection of Reports
    return Village.none if only_facilities.empty? && only_villages.empty?

    ary_of_ids = only_villages.pluck(:reportable_id)
    ary_of_ids += ary_of_village_ids_from_facilities if only_facilities.any?

    Village.all.where(id: ary_of_ids.uniq)
  end

  def self.related_cells
    # return a collection of Cells from a collection of Reports
    return Cell.none if only_facilities.empty? && only_villages.empty? && only_cells.empty?

    ary_of_ids = only_cells.pluck(:reportable_id)
    ary_of_ids += ary_of_cell_ids_from_villages if only_villages.any? || only_facilities.any?

    Cell.all.where(id: ary_of_ids.uniq)
  end

  def self.related_sectors
    # return a collection of Sectors from a collection of Reports
    return Sector.none if only_facilities.empty? && only_villages.empty? && only_cells.empty? && only_sectors.empty?

    ary_of_ids = only_sectors.pluck(:reportable_id)
    ary_of_ids += ary_of_sector_ids_from_cells if only_cells.any? || only_villages.any? || only_facilities.any?

    Sector.all.where(id: ary_of_ids.uniq)
  end

  def self.related_districts
    # return a collection of Districts from a collection of Reports
    return District.none if only_facilities.empty? && only_villages.empty? && only_cells.empty? && only_sectors.empty? && only_districts.empty?

    ary_of_ids = only_districts.pluck(:reportable_id)
    ary_of_ids += ary_of_district_ids_from_sectors if only_sectors.any? || only_cells.any? || only_villages.any? || only_facilities.any?

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

  def self.set_plans
    all.each { |rep| rep.send(:find_plan) }
  end

  private

  def flag_for_meaninglessness
    # if technology.is_engagement? :hours is required
    # else :distributed or :checked must have a value
    technology.is_engagement? ? errors.add(:hours, 'must be provided.') : errors.add(:distributed, 'or checked must be provided.')
  end

  def calculate_impact
    return unless distributed&.nonzero? || hours&.nonzero?

    technology.is_engagement? ? calculate_hours_impact : calculate_distributed_impact
  end

  def calculate_distributed_impact
    self.impact = if people&.positive?
                    people
                  elsif reportable_type == 'Facility' && reportable.population&.positive?
                    reportable.population
                  else
                    technology.default_impact * distributed.to_i
                  end
  end

  def calculate_hours_impact
    self.impact = if hours&.positive?
                    people * hours
                  else
                    people
                  end
  end

  def set_date_from_year_and_month
    self.date = Date.new(year, month, 1)
  end

  def set_year_and_month_from_date
    self.year = date.year
    self.month = date.month
  end

  def set_contract_from_date
    self.contract = Contract.between(date, date).first
  end

  def set_plan
    id = Plan.where(contract_id: contract_id,
                    technology_id: technology_id,
                    planable_id: reportable_id,
                    planable_type: reportable_type).limit(1).pluck(:id)[0].to_i

    return if id.zero?

    self.plan_id = id
  end

  def update_hierarchy
    return unless reportable.present?

    update_column(:hierarchy, reload.reportable.hierarchy)
  end
end
