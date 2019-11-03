# frozen_string_literal: true
require 'cache/cortex.rb'

# TODO Add after_save for create that calls self.reset_cache
#      https://apidock.com/rails/ActiveRecord/Callbacks/after_save

class District < ApplicationRecord
  include GeographyType

  belongs_to :country,    inverse_of: :districts

  has_many   :sectors,    inverse_of: :district, dependent: :destroy
  has_many   :cells,      through: :sectors,     inverse_of: :district
  has_many   :villages,   through: :cells,       inverse_of: :district
  has_many   :facilities, through: :villages,    inverse_of: :district

  has_many   :reports,    as: :reportable,       inverse_of: :reportable
  has_many   :plans,      as: :planable,         inverse_of: :planable

  validates_presence_of :name, :country_id
  validates_uniqueness_of :gis_code, allow_nil: true

  scope :for_country,  ->(ids) { where(country_id: ids) }

  after_initialize :cortex
  GEO_CHILDREN = ['Sector', 'Cell', 'Village', 'Facility'].freeze

  def cortex
    return @dalli if @dalli
    @dalli = Cache::Cortex.new
  end

  def recall(key)
    cortex.get(key)
  end

  def reset_cache
    geographies = [self]
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
    Plan.where(planable_type: 'District', planable_id: self.id)
          .or(Plan.where(planable_type: 'Sector', planable_id: sector_ids))
          .or(Plan.where(planable_type: 'Cell', planable_id: cell_ids))
          .or(Plan.where(planable_type: 'Village', planable_id: village_ids))
          .or(Plan.where(planable_type: 'Facility', planable_id: facility_ids))
  end

  def related_reports
    Report.where(reportable_type: 'District', reportable_id: self.id)
          .or(Report.where(reportable_type: 'Sector', reportable_id: sector_ids))
          .or(Report.where(reportable_type: 'Cell', reportable_id: cell_ids))
          .or(Report.where(reportable_type: 'Village', reportable_id: village_ids))
          .or(Report.where(reportable_type: 'Facility', reportable_id: facility_ids))
  end

  def sector_ids
    return @sectors if @sectors
    key = key(__method__)
    ids = recall(key)
    if !ids
      ids = Sector.where(district_id: self.id).pluck(:id)
      cortex.set(key, ids)
    end
    @sectors = ids
  end

  def cell_ids
    return @cells if @cells
    key = key(__method__)
    ids = recall(key)
    if !ids
      ids = Cell.where(sector_id: sector_ids).pluck(:id)
      cortex.set(key, ids)
    end
    @cells = ids
  end

  def village_ids
    return @villages if @villages
    key = key(__method__)
    ids = recall(key)
    if !ids
      ids = Village.where(cell_id: cell_ids).pluck(:id)
      cortex.set(key, ids)
    end
    @villages = ids
  end

  def facility_ids
    return @facilities if @facilities
    key = key(__method__)
    ids = recall(key)
    if !ids
      ids = Facility.where(village_id: village_ids).pluck(:id)
      cortex.set(key, ids)
    end
    @facilities = ids
  end
end
