# frozen_string_literal: true

class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def homepage?
    true
  end

  def show?
    true
  end
end
