# frozen_string_literal: true

class ReportPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    @user
  end

  def dttb_index?
    @user
  end

  def show?
    @user
  end

  def new?
    @user&.report_manager?
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
  end

  def destroy?
    new?
  end
end
