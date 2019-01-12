# frozen_string_literal: true

class Plan < ApplicationRecord
  belongs_to :contract,   inverse_of: :plans
  belongs_to :technology, inverse_of: :plans
  serialize :model_gid

  validates_presence_of :contract_id, :technology_id, :model_gid, :goal

  scope :current,         -> { where(contract_id: Contract.current) }
  scope :only_districts,  -> { where('model_gid ILIKE ?', '%/District/%') }
  scope :only_sectors,    -> { where('model_gid ILIKE ?', '%/Sector/%') }
  scope :only_cells,      -> { where('model_gid ILIKE ?', '%/Cell/%') }
  scope :only_villages,   -> { where('model_gid ILIKE ?', '%/Village/%') }
  scope :only_facilities, -> { where('model_gid ILIKE ?', '%/Facility/%') }

  def self.related_to(record)
    case record.class.to_s
    when 'District'
      only_districts.where('model_gid LIKE ?', "%/#{record.id}")
    when 'Sector'
      only_sectors.where('model_gid LIKE ?', "%/#{record.id}")
    when 'Cell'
      only_cells.where('model_gid LIKE ?', "%/#{record.id}")
    when 'Village'
      gid = "gid://liters-tracker/Village/#{record.id}"
      where('model_gid = ?', gid)
    when 'Facility'
      only_facilities.where('model_gid LIKE ?', "%/#{record.id}")
    end
  end

  def model
    GlobalID::Locator.locate model_gid
  end

  def district
    model.district
  end

  def sector
    return model if model.class == Sector

    model.sector
  end

  def cell
    return model if model.class == Cell

    model.cell
  end

  def village
    return model if model.class == Village

    model.village
  end
end
