# frozen_string_literal: true

class FacilityPolicy
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
    @user&.admin? || @user&.can_manage_geography?
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

  def facility_error
    @user&.can_manage_reports?
  end

  def facility_created
    @user&.can_manage_reports?
  end
end
