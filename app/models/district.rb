# frozen_string_literal: true

class District < ApplicationRecord
  has_many :sectors, inverse_of: :district, dependent: :destroy
  has_many :cells, through: :sectors, inverse_of: :district
  has_many :villages, through: :cells, inverse_of: :district
  has_many :facilities, through: :villages, inverse_of: :district
  has_many :reports, as: :reportable, inverse_of: :reportable
  has_many :plans, as: :planable, inverse_of: :planable

  validates_presence_of :name
  validates_uniqueness_of :gis_code, allow_nil: true
end
