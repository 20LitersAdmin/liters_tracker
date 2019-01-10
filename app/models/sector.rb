# frozen_string_literal: true

class Sector < ApplicationRecord
  has_many :cells, inverse_of: :sector, dependent: :destroy
  belongs_to :district, inverse_of: :sectors
end
