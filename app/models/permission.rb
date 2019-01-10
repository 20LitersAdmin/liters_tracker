# frozen_string_literal: true

class Permission < ApplicationRecord
  belongs_to :user, inverse_of: :permissions
  
  serialize :model_class

  def model
    Object.const_get model_class
  end
end
