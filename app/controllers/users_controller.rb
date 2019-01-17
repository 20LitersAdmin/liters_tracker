# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]

  def homepage
    authorize User

    @user = current_user

    @can_create_reports = current_user.can_create?('Report')
    @can_update_reports = current_user.can_update?('Report')
    @can_read_data = current_user.can_read?('Data')
    @can_update_facilities = current_user.can_update?('Facility')
    @can_update_geography = current_user.can_update?('Village')
    @can_update_plans = current_user.can_update?('Plan')
    @can_update_users = current_user.can_update?('User')

    @nothing = !@can_create_updates &&
               !@can_update_updates &&
               !@can_read_reports &&
               !@can_update_facilities &&
               !@can_update_geography &&
               !@can_update_plans &&
               !@can_update_users &&
               !@can_read_data

    @admins = User.admins
  end

  def data
    authorize current_user
  end

  def index
    authorize @users = User.all
  end

  def show
  end

  def new
    authorize @user = User.new
  end

  def create
    authorize @user = User.new(user_params)

    if @user.save
      flash[:success] = 'User was successfully created'
      redirect_back(fallback_location: root_path)
    else
      render 'new'
    end
  end

  def edit
    @skip_password_message = 'Leave blank to keep current password'
  end

  def update
    params_to_use = user_params[:password].blank? ? user_params_no_pws : user_params

    if @user.update(params_to_use)
      flash[:success] = current_user == @user ? 'Your profile was successfully updated' : 'User was successfully updated'
      redirect_back(fallback_location: root_path)
    else
      render 'edit'
    end
  end

  def destroy
  end

  private

  def set_user
    authorize @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:fname, :lname, :admin, :email,
                                 :confirmed_at, :locked_at,
                                 :password, :password_confirmation)
  end

  def user_params_no_pws
    params.require(:user).permit(:fname, :lname, :admin, :email,
                                 :confirmed_at, :locked_at)
  end
end
