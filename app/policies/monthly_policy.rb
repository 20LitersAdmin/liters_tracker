# frozen_string_literal: true

class MonthlyPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    @user
  end

  def redirector?
    @user
  end

  def show?
    @user
  end
end
