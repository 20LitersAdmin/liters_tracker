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

  validates_presence_of :fname, :lname
  validates :email, presence: true, uniqueness: true
  validates_inclusion_of :admin, in: [true, false]

  scope :admins, -> { where(admin: true) }

  def name
    fname + ' ' + lname
  end
end
