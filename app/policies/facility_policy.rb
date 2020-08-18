# frozen_string_literal: true

class FacilityPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    @user
  end

  def show?
    @user
  end

  def new?
    @user&.geography_manager?
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

  def reassign?
    new?
  end

  def reassign_to?
    new?
  end
end
