# frozen_string_literal: true

class DistrictPolicy
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
    @user&.admin?
  end

  def children?
    new?
  end

  def descendants?
    new?
  end

  def hidden?
    new?
  end

  def make_visible?
    new?
  end
end
