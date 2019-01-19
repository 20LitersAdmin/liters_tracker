# frozen_string_literal: true

class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def homepage?
    @user
  end

  def data?
    @user
  end

  def index?
    raise ActiveRecord::RecordNotFound if @record.empty?

    @user
  end

  def show?
    @user&.admin? || @user == current_user
  end

  def new?
    @user&.admin?
  end

  def create?
    new?
  end

  def edit?
    @user&.admin? || @user == current_user
  end

  def update?
    new?
  end

  def destroy?
    new?
  end
end
