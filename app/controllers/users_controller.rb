# frozen_string_literal: true

class UsersController < ApplicationController
  include UserHelper

  before_action :set_user, only: %i[show edit update destroy]

  def data
    authorize User

    @user = current_user

    @admins = User.admins

    @lifetime_stats = Technology.report_worthy.map do |technology|
      next if technology.reports.distributions.empty?

      { stat: technology.lifetime_distributed, title: "#{technology.name}s" }
    end
    @global_impact = Technology.dashboard_worthy.map(&:lifetime_impact).sum
  end

  def geography
    # a series of links to all types of geographies
  end

  def index
    authorize @users = User.all.order(:lname)
  end

  def show
    redirect_to edit_user_path(@user)
  end

  def new
    authorize @user = User.new
  end

  def create
    authorize @user = User.new(user_params)

    if @user.save
      # Net::SMTPSyntaxError (501 Invalid command or cannot parse from address
      flash[:success] = 'User created'
      redirect_to users_path
    else
      render 'new'
    end
  end

  def edit
    @skip_password_message = 'Leave blank to keep current password'

    @name = current_user == @user ? 'your' : @user.name
  end

  def update
    params_to_use = user_params[:password].blank? ? user_params_no_pws : user_params

    if @user.update(params_to_use)
      flash[:success] = current_user == @user ? 'Your profile was updated' : 'User updated'
      redirect_to users_path
    else
      render 'edit'
    end
  end

  def destroy
    authorize @user.destroy

    flash[:success] = 'User destroyed'
    redirect_to users_path
  end

  private

  def set_user
    authorize @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:fname, :lname, :admin, :email,
                                 :confirmed_at, :locked_at, :unlock_token,
                                 :password, :password_confirmation,
                                 :can_manage_reports, :can_manage_contracts,
                                 :can_manage_geography, :can_manage_technologies)
  end

  def user_params_no_pws
    params.require(:user).permit(:fname, :lname, :admin, :email,
                                 :confirmed_at, :locked_at)
  end
end
