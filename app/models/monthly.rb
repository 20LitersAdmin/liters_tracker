# frozen_string_literal: true

class Monthly
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :year, :integer, default: -> { Date.today.year }
  attribute :month, :integer, default: -> { Date.today.month - 1 }

  validates_presence_of :year, :month
end
