# frozen_string_literal: true

class UsersController < ApplicationController
  include UserHelper

  before_action :set_user, only: %i[show edit update destroy permissions set_permissions]

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

    @permissions_link = current_user.can_read?('Permission')
    @edit_link = current_user.can_update?('User')
    @delete_link = current_user.can_delete?('User')

    @link_count = [@permissions_link, @edit_link, @delete_link].count(true)
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

  def permissions
    # set the checkboxes somehow
  end

  def set_permissions

    permissions_hash = translate_to_booleans user_permissions_params

    if all_global_permissions? user_permissions_params
      @user.update(admin: true) # auto-deletes existing permissions
      redirect_to users_path and return
    end

    if any_global_permissions? user_permissions_params
      # @user.write_global_permissions!(user_permissions_params[:global_permissions].to_h.symbolize_keys)

    # when all == "0" it actually writes everything to true
    # permissions.write_* expects booleans
      byebug
    end

    if any_geo_permissions? user_permissions_params
    end

    if any_info_permissions? user_permissions_params
    end

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

  def user_permissions_params
    params.require(:user).permit(global_permissions: {}, geo_permissions: {}, info_permissions: {}, permissions: {})
  end

  def user_individual_permissions
    params.require(:user).permit(permissions: {})
  end

  # {"utf8"=>"✓", "_method"=>"put", "authenticity_token"=>"eUX4w3RBodvj2MiMszZGVHfRjAhbzOb+9OVJF/2mdQCACbP7UOYNo/KF4bqYGLypSeOABitvJoVpOPL7FjmueA==", "commit"=>"Set Permissions",
  # "user"=>
  #   {"global_permissions"=>
  #     {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #   "geo_permissions"=>
  #     {"create"=>"0", "read"=>"1", "update"=>"0", "delete"=>"0"},
  #   "info_permissions"=>
  #     {"create"=>"0", "read"=>"1", "update"=>"0", "delete"=>"0"}
  #   "permissions"=>
  #     {"Cell"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "Contract"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "Data"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "District"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "Facility"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "Permission"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "Plan"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "Report"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "Sector"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "Target"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "Technology"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "User"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"},
  #     "Village"=>
  #       {"create"=>"0", "read"=>"0", "update"=>"0", "delete"=>"0"}
  #     }
  #   }, "controller"=>"users", "action"=>"set_permissions", "id"=>"2"}
end
