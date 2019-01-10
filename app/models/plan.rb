# frozen_string_literal: true

class Plan < ApplicationRecord
  belongs_to :contract
  belongs_to :technology

  serialize :model_gid
end
