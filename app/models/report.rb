# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :technology, inverse_of: :reports
  belongs_to :user,       inverse_of: :reports
  belongs_to :contract,   inverse_of: :reports, optional: true
  belongs_to :reportable, polymorphic: true
  has_one    :story, inverse_of: :report, dependent: :destroy

  belongs_to :plan, inverse_of: :reports, required: false

  validates_presence_of :date

  # form fields for simple_form
  attr_accessor :cell, :village

  scope :only_districts,  -> { where(reportable_type: 'District') }
  scope :only_sectors,    -> { where(reportable_type: 'Sector') }
  scope :only_cells,      -> { where(reportable_type: 'Cell') }
  scope :only_villages,   -> { where(reportable_type: 'Village') }
  scope :only_facilities, -> { where(reportable_type: 'Facility') }

  scope :within_month,    ->(date) { where(date: date.beginning_of_month..date.end_of_month) }
  scope :earliest_date,   -> { order(date: :asc).first.date }
  scope :latest_date,     -> { order(date: :asc).last.date }
  # even though this is simple, it matches Plan.between(), so it's nice.
  scope :between,         ->(from, to) { where(date: from..to) }

  # currently unused
  # scope :with_plans,      -> { joins('LEFT JOIN plans ON reports.contract_id = plans.contract_id AND reports.technology_id = plans.technology_id AND reports.reportable_id = plans.planable_id AND reports.reportable_type = plans.planable_type') }
  scope :with_stories,    -> { joins(:story).where.not(stories: { id: nil }) }

  scope :distributions,   -> { where.not(distributed: nil) }

  before_validation :set_year_and_month_from_date,  if: -> { (year.blank? || month.blank?) && date.present? }
  before_validation :set_date_from_year_and_month,  if: -> { date.blank? && year.present? && month.present? }
  before_validation :flag_for_meaninglessness,      if: -> { (distributed.nil? || distributed.zero?) && (checked.nil? || checked.zero?) }

  before_save :calculate_impact

  before_save :set_contract_from_date, if: -> { contract_id.blank? && date.present? }
  after_save :set_plan,                if: -> { contract_id.present? && plan_id.blank? }

  def breadcrumb
    @hierarchy = Constants::Geography::HIERARCHY
    position = @hierarchy.index(reportable_type)

    hsh = {}
    (position + 1).times do |idx|
      sym = @hierarchy[idx].downcase.to_sym

      hsh[@hierarchy[idx]] = reportable.send(sym).name
    end

    hsh
  end

  # adding rows to DataTable on sectors#report
  def data_table_array
    ary = []
    if technology.scale == 'Family'
      ary << reportable.cell&.name
      ary << reportable.village&.name
    else
      ary << reportable.facility&.name
    end

    ary << plan&.goal
    ary << distributed
    ary << people
    ary << checked
  end


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

  # def self.key_params_are_missing?(batch_process_params)
  #   batch_process_params[:technology_id].blank? ||
  #     batch_process_params[:master_date].blank? ||
  #     batch_process_params[:reports].count.zero?
  # end

  # def self.batch_process(batch_report_params, user_id)
  #   technology_id = batch_report_params[:technology_id].to_i
  #   fallback_date = batch_report_params[:master_date]

  #   batch_report_params[:reports].each do |report_params|
  #     process(report_params, technology_id, user_id, fallback_date)
  #   end
  # end

  # def self.process(report_params, technology_id, user_id, fallback_date)
  #   date_string = report_params[:date].blank? ? fallback_date : report_params[:date]
  #   date = Date.parse(date_string)

  #   # date searching must be a range for reports where technology.scale == 'Community'
  #   report = Report.where(
  #     date: date.beginning_of_month..date.end_of_month,
  #     technology_id: technology_id,
  #     reportable_id: report_params[:reportable_id].to_i,
  #     reportable_type: report_params[:reportable_type]
  #   ).first_or_initialize

  #   action = report.determine_action(report_params, user_id)

  #   return if action.zero?

  #   return report.destroy if action == 1

  #   report.tap do |rep|
  #     rep.user_id = user_id
  #     rep.distributed = report_params[:distributed]
  #     rep.checked = report_params[:checked]
  #     rep.people = report_params[:people]
  #     rep.date = date
  #   end
  #   report.save
  # end

  # def determine_action(params, user_id)
  #   # 0 = Skip (record is new and meaningful params are nil OR record persists and attributes match)
  #   # 1 = Destroy (record persists and meaningful params are nil)
  #   # 2 = Create (meaningful params are not nil)
  #   # 3 = Update (meaningful params are not nil)

  #   return 0 if new_record? &&
  #               !params[:distributed].to_i.positive? &&
  #               !params[:checked].to_i.positive?

  #   # handles the "equality" of nil and 0 by forcing conversion to integers
  #   # ensures dates match exactly for reports where technology.scale == 'Community'
  #   return 0 if persisted? &&
  #               self.user_id == user_id &&
  #               distributed.to_i == params[:distributed].to_i &&
  #               checked.to_i == params[:checked].to_i &&
  #               people.to_i == params[:people].to_i &&
  #               date == Date.parse(params[:date])

  #   return 1 if persisted? &&
  #               !params[:distributed].to_i.positive? &&
  #               !params[:checked].to_i.positive?

  #   return 2 if new_record?

  #   3 # if persisted?
  # end

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
    # either :distributed or :checked must have a value
    errors.add(:distributed, 'or checked must be provided.')
  end

  def calculate_impact
    return if distributed.nil? || distributed.zero?

    self.impact = if people&.positive?
                    people
                  elsif reportable_type == 'Facility' && reportable.population&.positive?
                    reportable.population
                  else
                    technology.default_impact * distributed.to_i
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
    # edge case: report saved outside of an existing contract timeframe, allow contract_id to be null
    self.contract = Contract.between(date, date).first
  end

  def set_plan
    id = Plan.where(contract_id: contract_id,
                    technology_id: technology_id,
                    planable_id: reportable_id,
                    planable_type: reportable_type).limit(1).pluck(:id)[0].to_i

    return if id.zero?

    if new_record?
      self.plan_id = id
    else
      update_columns(plan_id: id)
    end
  end
end
