# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :technology, inverse_of: :reports
  belongs_to :user,       inverse_of: :reports
  belongs_to :contract,   inverse_of: :reports
  belongs_to :reportable, polymorphic: true
  has_one    :story, inverse_of: :report

  validates_presence_of :date, :user_id, :contract_id, :technology_id, :reportable_type, :reportable_id

  scope :only_districts,  -> { where(reportable_type: 'District') }
  scope :only_sectors,    -> { where(reportable_type: 'Sector') }
  scope :only_cells,      -> { where(reportable_type: 'Cell') }
  scope :only_villages,   -> { where(reportable_type: 'Village') }
  scope :only_facilities, -> { where(reportable_type: 'Facility') }
  scope :within_month,    ->(date) { where(date: date.beginning_of_month..date.end_of_month) }
  scope :earliest_date,   -> { order(date: :asc).first.date }
  scope :latest_date,     -> { order(date: :asc).last.date }
  scope :sorted,          -> { order(date: :desc) }
  scope :between,         ->(from, to) { where(date: from..to) }
  scope :with_plans,      -> { joins('LEFT JOIN plans ON reports.contract_id = plans.contract_id AND reports.technology_id = plans.technology_id AND reports.reportable_id = plans.planable_id AND reports.reportable_type = plans.planable_type') }
  scope :with_stories,    -> { joins(:story).where.not(stories: { id: nil }) }

  scope :distributions,   -> { where.not(distributed: nil) }
  scope :checks,          -> { where.not(checked: nil) }

  before_save :calculate_impact

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

  def self.key_params_are_missing?(batch_process_params)
    batch_process_params[:technology_id].blank? ||
      batch_process_params[:contract_id].blank? ||
      batch_process_params[:master_date].blank? ||
      batch_process_params[:reports].count.zero?
  end

  def self.batch_process(batch_report_params, user_id)
    technology_id = batch_report_params[:technology_id].to_i
    contract_id = batch_report_params[:contract_id].to_i
    fallback_date = batch_report_params[:master_date]

    batch_report_params[:reports].each do |report_params|
      process(report_params, technology_id, contract_id, user_id, fallback_date)
    end
  end

  def self.process(report_params, technology_id, contract_id, user_id, fallback_date)
    date = report_params[:date].blank? ? fallback_date : report_params[:date]

    report = Report.where(
      date: date,
      technology_id: technology_id,
      reportable_id: report_params[:reportable_id].to_i,
      reportable_type: report_params[:reportable_type]
    ).first_or_initialize

    action = report.determine_action(report_params, contract_id, user_id)
    return if action.zero?

    return report.destroy if action == 1

    report.tap do |rep|
      rep.contract_id = contract_id
      rep.user_id = user_id
      rep.distributed = report_params[:distributed]
      rep.checked = report_params[:checked]
      rep.people = report_params[:people]
    end
    report.save
  end

  def determine_action(params, contract_id, user_id)
    # 0 = Skip (record is new and meaningful params are nil OR record persists and attributes match)
    # 1 = Destroy (record persists and meaningful params are nil)
    # 2 = Create (meaningful params are not nil)
    # 3 = Update (meaningful params are not nil)

    return 0 if new_record? &&
                !params[:distributed].to_i.positive? &&
                !params[:checked].to_i.positive?

    # handles the "equality" of nil and 0 by forcing conversion to integers
    return 0 if self.contract_id == contract_id &&
                self.user_id == user_id &&
                distributed.to_i == params[:distributed].to_i &&
                checked.to_i == params[:checked].to_i &&
                people.to_i == params[:people].to_i

    return 1 if persisted? &&
                !params[:distributed].to_i.positive? &&
                !params[:checked].to_i.positive?

    return 2 if new_record?

    3 # if persisted?
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

  def self.related_facilities
    # return a collection of Facilities from a collection of Reports
    return Facility.none if self.only_facilities.empty?

    ary = self.only_facilities.pluck(:reportable_id)
    Facility.all.where(id: ary)
  end

  def self.related_villages
    # return a collection of Villages from a collection of Reports
    return Village.none if self.only_facilities.empty? && self.only_villages.empty?

    ary_of_ids = self.only_villages.pluck(:reportable_id)
    ary_of_ids += self.ary_of_village_ids_from_facilities if self.only_facilities.any?

    Village.all.where(id: ary_of_ids.uniq)
  end

  def self.related_cells
    # return a collection of Cells from a collection of Reports
    return Cell.none if self.only_facilities.empty? && self.only_villages.empty? && self.only_cells.empty?

    ary_of_ids = self.only_cells.pluck(:reportable_id)
    ary_of_ids += self.ary_of_cell_ids_from_villages if self.only_villages.any? || self.only_facilities.any?

    Cell.all.where(id: ary_of_ids.uniq)
  end

  def self.related_sectors
    # return a collection of Sectors from a collection of Reports
    return Sector.none if self.only_facilities.empty? && self.only_villages.empty? && self.only_cells.empty? && self.only_sectors.empty?

    ary_of_ids = self.only_sectors.pluck(:reportable_id)
    ary_of_ids += self.ary_of_sector_ids_from_cells if self.only_cells.any? || self.only_villages.any? || self.only_facilities.any?

    Sector.all.where(id: ary_of_ids.uniq)
  end

  def self.related_districts
    # return a collection of Districts from a collection of Reports
    return District.none if self.only_facilities.empty? && self.only_villages.empty? && self.only_cells.empty? && self.only_sectors.empty? && self.only_districts.empty?

    ary_of_ids = self.only_districts.pluck(:reportable_id)
    ary_of_ids += self.ary_of_district_ids_from_sectors if self.only_sectors.any? || self.only_cells.any? || self.only_villages.any? || self.only_facilities.any?

    District.all.where(id: ary_of_ids.uniq)
  end

  private

  def calculate_impact
    return if distributed.nil? || distributed.zero?

    if people&.positive?
      self.impact = people
    elsif reportable_type == 'Facility' && reportable.population&.positive?
      self.impact = reportable.population
    else
      self.impact = technology.default_impact * distributed.to_i
    end
  end
end
