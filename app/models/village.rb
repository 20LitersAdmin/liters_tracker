# frozen_string_literal: true

class Village < ApplicationRecord
  belongs_to :cell,     inverse_of: :villages
  has_many :facilities, inverse_of: :village, dependent: :destroy
  has_one :sector, through: :cell, inverse_of: :villages
  has_one :district, through: :sector, inverse_of: :villages

  validates_presence_of :name, :cell_id
  validates_uniqueness_of :gis_id, allow_nil: true

  def related_plans
    Plan.where(model_gid: "gid://liters-tracker/Village/#{id}")
  end

  def related_reports
    Report.where(model_gid: "gid://liters-tracker/Village/#{id}")
  end

  def pop_hh
    pop = population.present? ? ActiveSupport::NumberHelper.number_to_delimited(population, delimiter: ',') : '-'
    hh = households.present? ? ActiveSupport::NumberHelper.number_to_delimited(households, delimiter: ',') : '-'
    pop + ' / ' + hh
  end

  def village
    self
  end
end
