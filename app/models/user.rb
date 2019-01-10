# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  #:timeoutable, :trackable, :omniauthable
  devise :database_authenticatable,
         :confirmable,
         :lockable,
         :recoverable,
         :rememberable,
         :validatable

  has_many :permissions, inverse_of: :user, dependent: :destroy

  def name
    fname + ' ' + lname
  end

  def grant_global_permissions!(create: false, read: false, update: false, delete: false, all: false)
    Constants::Application::MODEL_LIST.each do |model|
      grant_permission_to!(model, create: create, read: read, update: update, delete: delete, all: all)
    end
  end

  def grant_permission_to!(model_name, create: false, read: false, update: false, delete: false, all: false)
    return false unless Constants::Application::MODEL_LIST.include? model_name

    record = permissions.where(model_class: model_name).first_or_initialize
    if all
      record.tap do |up|
        up.can_create = true
        up.can_read = true
        up.can_update = true
        up.can_delete = true
      end
    else
      record.tap do |up|
        up.can_create = create
        up.can_read = read
        up.can_update = update
        up.can_delete = delete
      end
    end
    record.save
  end
end
