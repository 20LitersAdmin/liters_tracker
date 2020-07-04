# frozen_string_literal: true

class StoryPolicy
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
    true
  end

  def new?
    @user&.reports_manager?
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

  def image?
    new?
  end

  def upload_image?
    new?
  end

  def rotate_image?
    new?
  end

  def destroy_image?
    new?
  end
end
