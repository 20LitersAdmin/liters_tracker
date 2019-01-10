# frozen_string_literal: true

class Cell < ApplicationRecord
  has_many :villages, inverse_of: :cell, dependent: :destroy
  belongs_to :sector, inverse_of: :cells

  def district
    sector.district
  end
end
