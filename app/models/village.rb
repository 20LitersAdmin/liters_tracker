# frozen_string_literal: true

require 'cache/cortex.rb'

# TODO: Add after_save for create that calls self.reset_cache
#      https://apidock.com/rails/ActiveRecord/Callbacks/after_save

class Village < ApplicationRecord
  include GeographyType

  belongs_to :cell,       inverse_of: :villages

  has_one    :sector,     through: :cell,     inverse_of: :villages
  has_one    :district,   through: :sector,   inverse_of: :villages
  has_one    :country,    through: :district, inverse_of: :villages

  has_many   :facilities, inverse_of: :village, dependent: :destroy

  has_many   :reports,    as: :reportable, inverse_of: :reportable
  has_many   :plans,      as: :planable,   inverse_of: :planable

  validates_presence_of :name, :cell_id
  validates_uniqueness_of :gis_code, allow_blank: true

  scope :for_cell, ->(ids) { where(cell_id: ids) }

  after_initialize :cortex
  after_save :reset_cache

  GEO_CHILDREN = %w[Facility].freeze

  def cortex
    return @dalli if @dalli

    @dalli = Cache::Cortex.new
  end

  def recall(key)
    cortex.get(key)
  end

  def reset_cache
    geographies = [self, self.cell, self.sector, self.district]
    geographies.each do |geo|
      ids = geo.class.all.pluck(:id)
      ids.each do |id|
        geo.class::GEO_CHILDREN.each do |child|
          cortex.delete("#{id}_#{child}")
        end
      end
    end
  end

  def key(method_name)
    geo_name = method_name.to_s.split('_').first.capitalize
    "#{self.id}_#{geo_name}"
  end

  def related_plans
    Plan.where(planable_type: 'Village', planable_id: id)
        .or(Plan.where(planable_type: 'Facility', planable_id: facility_ids))
  end

  def related_reports
    Report.where(reportable_type: 'Village', reportable_id: id)
          .or(Report.where(reportable_type: 'Facility', reportable_id: facility_ids))
  end

  def facility_ids
    return @facilities if @facilities

    key = key(__method__)
    ids = recall(key)

    unless ids
      ids = Facility.where(village_id: self.id).pluck(:id)
      cortex.set(key, ids)
    end

    @facilities = ids
  end

  # def pop_hh
  #   pop = population.present? ? ActiveSupport::NumberHelper.number_to_delimited(population, delimiter: ',') : '-'
  #   hh = households.present? ? ActiveSupport::NumberHelper.number_to_delimited(households, delimiter: ',') : '-'
  #   "#{pop} / #{hh}"
  # end

  def village
    # Reports and Plans have `.model` which needs to respond to `report.model.village`
    self
  end
end
