# frozen_string_literal: true

class Village < ApplicationRecord
  belongs_to :cell,     inverse_of: :villages
  has_many :facilities, inverse_of: :village, dependent: :destroy
  has_one :sector, through: :cell, inverse_of: :villages
  has_one :district, through: :sector, inverse_of: :villages
  has_many :reports, as: :reportable, inverse_of: :reportable
  has_many :plans, as: :planable, inverse_of: :planable

  validates_presence_of :name, :cell_id
  validates_uniqueness_of :gis_code, allow_blank: true

  def pop_hh
    pop = population.present? ? ActiveSupport::NumberHelper.number_to_delimited(population, delimiter: ',') : '-'
    hh = households.present? ? ActiveSupport::NumberHelper.number_to_delimited(households, delimiter: ',') : '-'
    "#{pop} / #{hh}"
  end

  def village
    # Reports and Plans have `.model` which needs to respond to `report.model.village`
    self
  end
end
