# frozen_string_literal: true

class Target < ApplicationRecord
  belongs_to :contract,   inverse_of: :targets
  belongs_to :technology, inverse_of: :targets

  validates_presence_of :contract_id, :technology_id, :goal
end
