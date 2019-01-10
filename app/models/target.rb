# frozen_string_literal: true

class Target < ApplicationRecord
  belongs_to :contract
  belongs_to :technology
end
