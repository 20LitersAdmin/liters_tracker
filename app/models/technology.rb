# frozen_string_literal: true

class Technology < ApplicationRecord
  has_many :reports, inverse_of: :technology
  has_many :targets, inverse_of: :technology
  has_many :plans,   inverse_of: :technology

  validates_presence_of :name, :short_name, :default_impact
  validates_inclusion_of :agreement_required, in: [true, false]
  validates :scale, inclusion: { in: Constants::Technology::SCALE, message: "Must be one of these: #{Constants::Technology::SCALE.to_sentence}" }

  monetize :direct_cost_cents, :indirect_cost_cents, :us_cost_cents, :local_cost_cents, allow_nil: true, allow_blank: true
end
