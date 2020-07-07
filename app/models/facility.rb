# frozen_string_literal: true

class Facility < ApplicationRecord
  include GeographyType
  include Rails.application.routes.url_helpers

  belongs_to :village,  inverse_of: :facilities

  has_one    :cell,     through: :village,  inverse_of: :facilities
  has_one    :sector,   through: :cell,     inverse_of: :facilities
  has_one    :district, through: :sector,   inverse_of: :facilities
  has_one    :country,  through: :district, inverse_of: :facilities

  has_many   :reports,  as: :reportable, inverse_of: :reportable
  has_many   :plans,    as: :planable,   inverse_of: :planable

  validates_presence_of :name
  validates :category, inclusion: { in: Constants::Facility::CATEGORY, message: "must be one of these: #{Constants::Facility::CATEGORY.to_sentence}" }

  scope :churches,     -> { where(category: 'Church') }
  scope :not_churches, -> { where.not(category: 'Church') }

  after_save :update_hierarchy, if: -> { saved_change_to_village_id? }

  def impact
    population.to_i + (households.to_i * Constants::Population::HOUSEHOLD_SIZE)
  end

  # Even though facilities don't have any children,
  # all geographies need to respond to related_reports
  def related_reports
    reports
  end

  # Even though facilities don't have any children,
  # all geographies need to respond to related_plans
  def related_plans
    plans
  end

  def related_stories
    Story.joins(:report).where("reports.reportable_type = 'Facility' AND reports.reportable_id = ?", id)
  end

  def facility
    self
  end

  def parent
    village
  end

  def update_hierarchy
    update_column(:hierarchy, village.hierarchy << { parent_name: village.name, parent_type: village.class.to_s, link: village_path(village) })

    reload
  end
end
