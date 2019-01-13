# frozen_string_literal: true

class Target < ApplicationRecord
  belongs_to :contract,   inverse_of: :targets
  belongs_to :technology, inverse_of: :targets

  validates_presence_of :contract_id, :technology_id, :goal

  scope :between, ->(sdate, edate) { joins(:contract).where('contracts.start_date BETWEEN ? AND ?', sdate, edate) }

  def date
    contract.end_date
  end
end
