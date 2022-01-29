# frozen_string_literal: true

module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from Pundit::NotAuthorizedError do
      if current_user
        flash[:error] = 'You do not have permission'
        redirect_to root_path
      else
        flash[:error] = 'You need to sign in first'
        redirect_to new_user_session_path
      end
    end
    rescue_from ActiveRecord::RecordNotFound do
      flash[:error] = 'Nothing was found'
      redirect_to root_path
    end
  end
end
