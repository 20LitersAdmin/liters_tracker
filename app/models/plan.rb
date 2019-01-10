# frozen_string_literal: true

class Plan < ApplicationRecord
  belongs_to :contract,   inverse_of: :plans
  belongs_to :technology, inverse_of: :plans
  serialize :model_gid

  validates_presence_of :contract_id, :technology_id, :model_gid, :goal
end
