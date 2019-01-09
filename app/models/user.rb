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

  def name
    fname + ' ' + lname
  end
end
