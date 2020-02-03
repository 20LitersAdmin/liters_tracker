# frozen_string_literal: true

class Monthly
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :year, :integer, default: -> { Date.today.last_month.year }
  attribute :month, :integer, default: -> { Date.today.last_month.month }

  validates_presence_of :year, :month
end
