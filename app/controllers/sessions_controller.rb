# frozen_string_literal: true

class SessionsController < Devise::SessionsController
  def new
    # TODO: remove this handy method before final deploy
    User.first.reset_password('password', 'password') if Rails.env.development?

    super
  end
end
