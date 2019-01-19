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
  has_many :reports,     inverse_of: :user

  validates_presence_of :fname, :lname
  validates :email, presence: true, uniqueness: true
  validates_inclusion_of :admin, in: [true, false]

  scope :admins, -> { where(admin: true) }

  before_save :admins_dont_need_permission, if: -> { admin? }

  # attr_accessor :global_permissions, :geo_permissions, :info_permissions, :permissions

  def name
    fname + ' ' + lname
  end

  def can_create?(model_name)
    return true if admin?

    return false unless permissions.where(model_class: model_name).any?

    permissions.where(model_class: model_name).first.can_create?
  end

  def can_delete?(model_name)
    return true if admin?

    return false unless permissions.where(model_class: model_name).any?

    permissions.where(model_class: model_name).first.can_delete?
  end

  def can_read?(model_name)
    return true if admin?

    return false unless permissions.where(model_class: model_name).any?

    permissions.where(model_class: model_name).first.can_read?
  end

  def can_update?(model_name)
    return true if admin?

    return false unless permissions.where(model_class: model_name).any?

    permissions.where(model_class: model_name).first.can_update?
  end

  def write_global_permissions!(args)
    return true if admin?

    case args[:scope]
    when 'geo'
      scope = Constants::Geography::STACK_ARY
    when 'info'
      scope = Constants::Application::INFO_MODELS_LIST
    else
      scope = Constants::Application::MODEL_LIST
    end

    scope.each do |model|
      write_permission!(model, args)
    end
  end

  def write_permission!(model_name, args)
    return true if admin?

    return false unless Constants::Application::MODEL_LIST.include? model_name

    permission = permissions.where(model_class: model_name).first_or_initialize

    return permission.write_all(args[:all]) if args[:all].present?

    permission.write_individual(args)
  end

  private

  def admins_dont_need_permission
    return true if permissions.empty?

    permissions.destroy_all
  end
end
