# frozen_string_literal: true

class Permission < ApplicationRecord
  belongs_to :user, inverse_of: :permissions, dependent: :destroy
  serialize :model_class

  validates_presence_of :user_id
  validates :model_class, inclusion: { in: Constant::Application::MODEL_LIST, message: "must be one of these #{Constant::Application::MODEL_LIST.to_sentence}" }
  validates_inclusion_of :can_create, :can_read, :can_update, :can_delete, in: [true, false]

  def model
    Object.const_get model_class
  end
end
