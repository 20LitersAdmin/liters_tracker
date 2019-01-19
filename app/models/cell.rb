# frozen_string_literal: true

class Cell < ApplicationRecord
  belongs_to :sector, inverse_of: :cells
  has_many :villages, inverse_of: :cell, dependent: :destroy
  has_many :facilities, through: :villages, inverse_of: :cell
  has_one :district, through: :sector, inverse_of: :cells

  validates_presence_of :name, :sector_id
  validates_uniqueness_of :gis_id, allow_nil: true
end
