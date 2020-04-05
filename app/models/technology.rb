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
  scope :dashboard_worthy, -> { where(dashboard_worthy: true) }

  before_save :community_engagement_is_family_scale, if: -> { is_engagement? && scale == 'Community' }

  def default_household_impact
    default_impact.to_i / Constants::Population::HOUSEHOLD_SIZE
  end

  def lifetime_impact
    reports.distributions.sum(:impact)
  end

  def lifetime_distributed
    if is_engagement?
      reps = reports.with_hours.select(:hours, :people)
      reps.sum(:hours) * reps.sum(:people)
    else
      reports.distributions.sum(:distributed)
    end
  end

  def plural_name
    if is_engagement?
      "#{name} hours"
    else
      name.pluralize
    end
  end

  def type
    return 'engagement' if is_engagement?

    scale.downcase
  end

  def type_for_form
    scale == 'Community' ? 'facility' : 'village'
  end

  private

  def community_engagement_is_family_scale
    self.scale = 'Family'
  end
end
