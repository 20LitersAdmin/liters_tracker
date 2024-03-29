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

  def cells
    # Report and Plan want to be able to call any geography
    cell&.parent&.cells
  end

  def districts
    # Report and Plan want to be able to call any geography
    district&.parent&.districts
  end

  def facility
    # Report and Plan want to be able to call any geography
    self
  end

  def facilities
    # Report and Plan want to be able to call any geography
    parent&.facilities
  end

  def has_reports_or_plans?
    reports.any? || plans.any?
  end

  def impact
    population.to_i + (households.to_i * Constants::Population::HOUSEHOLD_SIZE)
  end

  def parent
    village
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

  def sectors
    # Report and Plan want to be able to call any geography
    sector&.parent&.sectors
  end

  def similar_by_name
    # split the downcased name by word, then remove any non-letter words from the array
    split = name.downcase.gsub(/[^a-z ]/, '').split(' ') - Constants::Facility::NAME_STRIP

    return unless split.any?

    id_ary = []

    split.each do |frag|
      id_ary << Facility.where('name ~* ?', frag).pluck(:id)
    end

    final_ary = id_ary.flatten.uniq - [id]
    Facility.where(id: final_ary).order(:name)
  end

  def update_hierarchy
    update_column(:hierarchy, village.hierarchy << { parent_name: village.name, parent_type: village.class.to_s, link: village_path(village) })

    reload
  end

  def villages
    # Report and Plan want to be able to call any geography
    village&.parent&.villages
  end
end
