# frozen_string_literal: true

class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def data?
    @user
  end

  def index?
    raise ActiveRecord::RecordNotFound if @record.empty?

    @user
  end

  def show?
    @user&.admin? || @user == @record
  end

  def new?
    @user&.admin?
  end

  def create?
    new?
  end

  def edit?
    @user&.admin? || @user == @record
  end

  def update?
    new?
  end

  def destroy?
    new?
  end

  def batch_process?
    @user&.admin? || @user&.can_manage_reports?
  end
end
