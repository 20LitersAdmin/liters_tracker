# frozen_string_literal: true

class ContractPolicy
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
    @user&.contract_manager?
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
end
