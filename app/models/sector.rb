# frozen_string_literal: true

class Sector < ApplicationRecord
  include GeographyType

  belongs_to :district,   inverse_of: :sectors

  has_one    :country,    through: :district, inverse_of: :sectors

  has_many   :cells,      inverse_of: :sector, dependent: :destroy
  has_many   :villages,   through: :cells,     inverse_of: :sector
  has_many   :facilities, through: :villages,  inverse_of: :sector
  has_many   :reports,    as: :reportable,     inverse_of: :reportable
  has_many   :plans,      as: :planable,       inverse_of: :planable

  validates_presence_of :name, :district_id
  validates_uniqueness_of :gis_code, allow_blank: true

  scope :for_district,  ->(ids) { where(district_id: ids) }

  after_initialize :cortex
  GEO_CHILDREN = ['Cell', 'Village', 'Facility'].freeze

  def cortex
    return @dalli if @dalli
    @dalli = Cache::Cortex.new
  end

  def recall(key)
    cortex.get(key)
  end

  def reset_cache
    ids = Sector.all.pluck(:id)
    ids.each do |id|
      GEO_CHILDREN.each do |child|
        cortex.delete("#{id}_#{child}")
      end
    end
  end

  def key(method_name)
    geo_name = method_name.to_s.split('_').first.capitalize
    "#{self.id}_#{geo_name}"
  end

  def related_plans
    Plan.where(planable_type: 'Sector', planable_id: self.id)
          .or(Plan.where(planable_type: 'Cell', planable_id: cell_ids))
          .or(Plan.where(planable_type: 'Village', planable_id: village_ids))
          .or(Plan.where(planable_type: 'Facility', planable_id: facility_ids))
  end

  def related_reports
    Report.where(reportable_type: 'Sector', reportable_id: self.id)
          .or(Report.where(reportable_type: 'Cell', reportable_id: cell_ids))
          .or(Report.where(reportable_type: 'Village', reportable_id: village_ids))
          .or(Report.where(reportable_type: 'Facility', reportable_id: facility_ids))
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
