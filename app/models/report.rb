# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :technology, inverse_of: :reports
  belongs_to :user,       inverse_of: :reports
  belongs_to :contract,   inverse_of: :reports
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
    where('model_gid = ?', "gid://liters-tracker/#{record.class}/#{record.id}")
  end

  def people_served
    model_gid.include?('Facility') && model.impact.positive? ? model.impact : (technology.default_impact * distributed.to_i )
  end
end
