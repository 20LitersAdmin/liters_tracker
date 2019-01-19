# frozen_string_literal: true

class Village < ApplicationRecord
  belongs_to :cell,     inverse_of: :villages
  has_many :facilities, inverse_of: :village
  has_one :sector, through: :cell, inverse_of: :villages
  has_one :district, through: :sector, inverse_of: :villages

  validates_presence_of :name, :cell_id
  validates_uniqueness_of :gis_id, allow_nil: true

  def current_plan
    Plan.where(contract_id: Constants::Contract::CURRENT).where(model_gid: "gid://liters-tracker/Village/#{id}").last
  end

  def related_reports
    Report.where(model_gid: "gid://liters-tracker/Village/#{id}")
  end
end
