# frozen_string_literal: true

class Update < ApplicationRecord
  belongs_to :technology, inverse_of: :updates
  belongs_to :user,       inverse_of: :updates
  serialize :model_gid

  scope :only_districts,  -> { where('model_gid ILIKE ?', '%/District/%') }
  scope :only_sectors,    -> { where('model_gid ILIKE ?', '%/Sector/%') }
  scope :only_cells,      -> { where('model_gid ILIKE ?', '%/Cell/%') }
  scope :only_villages,   -> { where('model_gid ILIKE ?', '%/Village/%') }
  scope :only_facilities, -> { where('model_gid ILIKE ?', '%/Facility/%') }

  def model
    GlobalID::Locator.locate model_gid
  end

  def self.related_to(record)
    case record.class.to_s
    when 'District'
      only_districts.where('model_gid ILIKE ?', "%/#{record.id}%")
    when 'Sector'
      only_sectors.where('model_gid ILIKE ?', "%/#{record.id}%")
    when 'Cell'
      only_cells.where('model_gid ILIKE ?', "%/#{record.id}%")
    when 'Village'
      only_villages.where('model_gid ILIKE ?', "%/#{record.id}%")
    when 'Facility'
      only_facilities.where('model_gid ILIKE ?', "%/#{record.id}%")
    end
  end

  def district
    model.district
  end

  def sector
    return model if model.class == 'sector'

    model.sector
  end

  def cell
    model.cell
  end
end
