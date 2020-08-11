# frozen_string_literal: true

class Contract < ApplicationRecord
  has_many :targets, inverse_of: :contract, dependent: :destroy
  has_many :plans,   inverse_of: :contract, dependent: :destroy
  has_many :reports, inverse_of: :contract

  accepts_nested_attributes_for :plans, :targets

  validates_presence_of :start_date, :end_date

  scope :current, -> { where('end_date > ?', Date.today).order(start_date: :desc).first }

  scope :between, ->(from, to) { where('end_date >= ? AND start_date <= ?', from, to) }

  after_save :set_name
  after_create :find_reports

  def url_params
    "?from=#{start_date.strftime('%Y-%m-%d')}&to=#{end_date.strftime('%Y-%m-%d')}"
  end

  private

  def find_reports
    # edge case: reports have been created without a contract_id
    # add contract_id to these records once an applicable contract is created
    reps = Report.where(contract_id: nil).between(start_date, end_date)

    reps.update_all(contract_id: id) if reps.any?
  end

  def set_name
    update_column(:name, "#{id}: #{start_date.strftime('%m/%Y')} - #{end_date.strftime('%m/%Y')}")
  end
end
