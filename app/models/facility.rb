# frozen_string_literal: true

class Facility < ApplicationRecord
  include GeographyType

  belongs_to :village,  inverse_of: :facilities

  has_one    :cell,     through: :village,  inverse_of: :facilities
  has_one    :sector,   through: :cell,     inverse_of: :facilities
  has_one    :district, through: :sector,   inverse_of: :facilities
  has_one    :country,  through: :district, inverse_of: :facilities

  has_many   :reports,  as: :reportable, inverse_of: :reportable
  has_many   :plans,    as: :planable,   inverse_of: :planable

  validates_presence_of :name, :village_id
  validates :category, inclusion: { in: Constants::Facility::CATEGORY, message: "must be one of these: #{Constants::Facility::CATEGORY.to_sentence}" }

  scope :churches,     -> { where(category: 'Church') }
  scope :not_churches, -> { where.not(category: 'Church') }

  scope :for_village,  ->(ids) { where(village_id: ids) }

  def impact
    population.to_i + (households.to_i * Constants::Population::HOUSEHOLD_SIZE)
  end
end
