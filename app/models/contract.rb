# frozen_string_literal: true

class Contract < ApplicationRecord
  has_many :targets, inverse_of: :contract, dependent: :destroy
  has_many :plans,   inverse_of: :contract, dependent: :destroy

  validates_presence_of :start_date, :end_date
end
