# frozen_string_literal: true

class Permission < ApplicationRecord
  belongs_to :user, inverse_of: :permissions
  serialize :model_class

  validates_presence_of :user_id
  validates :model_class, inclusion: { in: Constants::Application::MODEL_LIST, message: "must be one of these #{Constants::Application::MODEL_LIST.to_sentence}" }
  validates_inclusion_of :can_create, :can_read, :can_update, :can_delete, in: [true, false]

  def model
    Object.const_get model_class
  end

  def write_all(boolean)
    tap do |s|
      s.can_create =  !!boolean
      s.can_read =    !!boolean
      s.can_update =  !!boolean
      s.can_delete =  !!boolean
      s.save!
    end
  end

  def write_individual(args)
    tap do |s|
      s.can_create =  args[:create] if args[:create].present?
      s.can_read =    args[:read]   if args[:read].present?
      s.can_update =  args[:update] if args[:update].present?
      s.can_delete =  args[:delete] if args[:delete].present?
      s.save!
    end
  end
end
