# frozen_string_literal: true

class ReportPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    @user.report_manager?
  end

  def dttb_index?
    @user.report_manager?
  end

  def show?
    @user.report_manager?
  end

  def new?
    show?
  end

  def create?
    show?
  end

  def edit?
    show?
  end

  def update?
    show?
  end

  def destroy?
    show?
  end
end
