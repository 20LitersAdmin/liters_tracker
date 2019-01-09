# frozen_string_literal: true

class UsersController < ApplicationController
  def homepage
    if !current_user
      redirect_to new_user_session_path 
    else
      authorize @user = current_user
    end
  end
end
