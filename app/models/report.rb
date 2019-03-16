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
  scope :within_month, ->(date) { where(date: date.beginning_of_month..date.end_of_month) }

  def self.related_to(record)
    where(model_gid: record.to_global_id.to_s)
  end

  def self.related_to_facility(facility, only_ary: false)
    reports = related_to(facility)

    return reports.pluck(:id) if only_ary

    reports
  end

  def self.related_to_village(village, only_ary: false)
    report_ids = []
    report_ids << related_to(village).pluck(:id)
    village.facilities.each { |facility| report_ids << related_to_facility(facility, only_ary: true) }

    return report_ids.flatten.uniq if only_ary

    where(id: report_ids.flatten.uniq)
  end

  def self.related_to_cell(cell, only_ary: false)
    report_ids = []
    report_ids << related_to(cell).pluck(:id)
    cell.villages.each { |village| report_ids << related_to_village(village, only_ary: true) }

    return report_ids.flatten.uniq if only_ary

    where(id: report_ids.flatten.uniq)
  end

  def self.related_to_sector(sector, only_ary: false)
    report_ids = []
    report_ids << related_to(sector).pluck(:id)
    sector.cells.each { |cell| report_ids << related_to_cell(cell, only_ary: true) }

    return report_ids.flatten.uniq if only_ary

    where(id: report_ids.flatten.uniq)
  end

  def self.related_to_district(district)
    report_ids = []
    report_ids << related_to(district).pluck(:id)
    district.sectors.each { |sector| report_ids << Report.related_to_sector(sector, only_ary: true) }

    where(id: report_ids.flatten.uniq)
  end

  def self.earliest_date
    self.all.order(date: :asc).first.date
  end

  def self.latest_date
    self.all.order(date: :asc).last.date
  end

  def self.key_params_are_missing?(batch_process_params)
    batch_process_params[:technology_id].blank? ||
      batch_process_params[:contract_id].blank? ||
      batch_process_params[:reports].count.zero?
  end

  def self.batch_process(batch_report_params, user_id)
    technology_id = batch_report_params[:technology_id].to_i
    contract_id = batch_report_params[:contract_id].to_i

    batch_report_params[:reports].each do |report_params|
      process(report_params, technology_id, contract_id, user_id)
    end
  end

  def self.process(report_params, technology_id, contract_id, user_id)
    report = Report.where(date: report_params[:date], model_gid: report_params[:model_gid], technology_id: technology_id).first_or_initialize
    action = report.determine_action(report_params, contract_id, user_id)

    return if action.zero?

    return report.destroy if action == 1

    report.tap do |rep|
      rep.contract_id = contract_id
      rep.user_id = user_id
      rep.distributed = report_params[:distributed]
      rep.checked = report_params[:checked]
      rep.people = report_params[:people]
      rep.households = report_params[:households]
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
                people.to_i == params[:people].to_i &&
                households.to_i == params[:households].to_i

    return 1 if persisted? &&
                !params[:distributed].to_i.positive? &&
                !params[:checked].to_i.positive?

    return 2 if new_record?

    3 # if persisted?
  end

  def model
    GlobalID::Locator.locate model_gid
  end

  def people_served
    return people if people&.positive?
    # I don't love this, but right now every data view utilizes people_served
    # and there are cases, like RWHS and SAM2 reports where people is nil and households is positive
    # I need to switch to using impact for all report calculations
    return households_impact if households&.positive?

    model_gid.include?('Facility') && model.population&.positive? ? model.population : (technology.default_impact * distributed.to_i)
  end

  def households_served
    return households if households&.positive?

    model_gid.include?('Facility') && model.households&.positive? ? model.households : (technology.default_household_impact * distributed.to_i)
  end

  def households_impact
    households.to_i * Constants::Population::HOUSEHOLD_SIZE
  end

  def impact
    # use this on all data views instead of calculating from people_served
    people_served > households_impact ? people_served : households_impact
  end
end
