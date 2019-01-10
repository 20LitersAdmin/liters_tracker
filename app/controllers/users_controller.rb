# frozen_string_literal: true

class UsersController < ApplicationController
  def homepage
    verify_user_logged_in and return

    authorize @user = current_user
  end

  def show
    authorize @user = current_user
  end

  private

  def verify_user_logged_in
    unless current_user
      authorize User
      redirect_to new_user_session_path and return true
    end
  end
end
