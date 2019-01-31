# frozen_string_literal: true

class ReportPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    raise ActiveRecord::RecordNotFound if @record.empty?

    @user
  end

  def show?
    @user
  end

  def new?
    @user&.admin? || @user&.can_manage_reports?
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
    @user&.admin?
  end

  def batch_process?
    @user&.admin? || @user&.can_manage_reports?
  end
end
