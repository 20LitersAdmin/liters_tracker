# frozen_string_literal: true

class Country < ApplicationRecord
  include GeographyNaming

  has_many :districts,  inverse_of: :country
  has_many :sectors,    through: :districts, inverse_of: :country
  has_many :cells,      through: :sectors,   inverse_of: :country
  has_many :villages,   through: :cells,     inverse_of: :country
  has_many :facilities, through: :villages,  inverse_of: :country
  has_many :reports,    as: :reportable,     inverse_of: :reportable
  has_many :plans,      as: :planable,       inverse_of: :planable

  validates_presence_of :name
  validates_uniqueness_of :gis_code, allow_nil: true

  # see config/initializers/geography_naming.rb
  def country
    self
  end
end
