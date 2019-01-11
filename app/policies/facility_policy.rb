# frozen_string_literal: true

class FacilityPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    raise ActiveRecord::RecordNotFound if @record.empty?

    @user&.can_read?(@record.first.class.name)
  end

  def show?
    @user&.can_read?(@record.class.name)
  end

  def new?
    @user&.can_create?(@record.class.name)
  end

  def create?
    @user&.can_create?(@record.class.name)
  end

  def edit?
    @user&.can_update?(@record.class.name)
  end

  def update?
    @user&.can_update?(@record.class.name)
  end

  def destroy?
    @user&.can_delete?(@record.class.name)
  end
end
