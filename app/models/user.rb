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

  has_many :reports, inverse_of: :user
  has_many :stories, inverse_of: :user

  validates_presence_of :fname, :lname
  validates :email, presence: true, uniqueness: true
  validates_inclusion_of :admin, in: [true, false]

  scope :admins,              -> { where(admin: true) }
  scope :report_managers,     -> { admins.or(where(can_manage_reports: true)) }
  scope :geography_managers,  -> { admins.or(where(can_manage_geography: true)) }
  scope :contract_managers,   -> { admins.or(where(can_manage_contracts: true)) }
  scope :technology_managers, -> { admins.or(where(can_manage_technologies: true)) }

  def name
    "#{fname} #{lname}"
  end

  def report_manager?
    return true if admin?

    can_manage_reports?
  end

  def geography_manager?
    return true if admin?

    can_manage_geography?
  end

  def contract_manager?
    return true if admin?

    can_manage_contracts?
  end

  def technology_manager?
    return true if admin?

    can_manage_technologies?
  end
end
