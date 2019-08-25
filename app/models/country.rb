# frozen_string_literal: true

class Country < ApplicationRecord
  include GeographyType

  has_many :districts,  inverse_of: :country
  has_many :sectors,    through: :districts, inverse_of: :country
  has_many :cells,      through: :sectors,   inverse_of: :country
  has_many :villages,   through: :cells,     inverse_of: :country
  has_many :facilities, through: :villages,  inverse_of: :country
  has_many :reports,    as: :reportable,     inverse_of: :reportable
  has_many :plans,      as: :planable,       inverse_of: :planable

  validates_presence_of :name
  validates_uniqueness_of :gis_code, allow_nil: true

  def country
    # see config/initializers/geography_type.rb
    self
  end
end
