# frozen_string_literal: true

class District < ApplicationRecord
  has_many :sectors, dependent: :destroy
end