# frozen_string_literal: true

class Technology < ApplicationRecord
  has_many :reports, inverse_of: :technology
  has_many :targets, inverse_of: :technology
  has_many :plans,   inverse_of: :technology

  validates_presence_of :name, :short_name, :default_impact
  validates_inclusion_of :agreement_required, in: [true, false]
  validates :scale, inclusion: { in: Constants::Technology::SCALE, message: "Must be one of these: #{Constants::Technology::SCALE.to_sentence}" }

  monetize :direct_cost_cents, :indirect_cost_cents, :us_cost_cents, :local_cost_cents, allow_nil: true, allow_blank: true

  scope :report_worthy, -> { where(report_worthy: true) }

  def default_household_impact
    default_impact.to_i / Constants::Population::HOUSEHOLD_SIZE
  end

  def lifetime_impact
    reports.distributions.sum(:impact)
  end

  def lifetime_distributed
    reports.distributions.sum(:distributed)
  end

  def plural_name
    if name.include?('Training')
      ary = []
      split = name.split(' ')
      ary << split[0].pluralize
      ary << 'Trained'
      ary.join(' ')
    else
      name.pluralize
    end
  end
end
