
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit
  include ApplicationHelper
  include ErrorHandler
  protect_from_forgery with: :exception

  # https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  before_action :store_user_location!, if: :storable_user_location?

  after_action :save_old_params
  after_action :clear_previous_stories
  before_action :set_return_path
  before_action :save_previous_story

  private

  def save_previous_story
    # save the IDs of visited stories so they can be excluded from Story#related
    return unless url_params[:controller] == 'stories' && url_params[:action] == 'show'

    # create the hash if it doesn't exist
    session[:previous_stories] ||= []

    id = url_params[:id].to_i

    # save the current story's id into the hash
    session[:previous_stories] << id unless session[:previous_stories].include?(id)
  end

  def clear_previous_stories
    return unless url_params[:controller] == 'dashboard' && url_params[:action] == 'index'

    session[:previous_stories] = []
  end

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.
  def storable_user_location?
    request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  def save_old_params
    return false if bad_param?(params)

    session[:pre_previous] = session[:previous] unless params_match?(session[:previous], params)
    session[:previous] = url_params
  end

  def set_return_path
    conditions =
      request.referer.present? &&
      # current path is different from previous path
      request.fullpath != URI(request.referer).path

    # start with default_path vs. request.referer
    back = conditions ? request.referer : default_path
    # switch to session[:previous] unless it's bad
    back = build_url(session[:previous]) unless bad_param?(session[:previous])
    # switch to session[:pre_previous] if it exists, if the current path matches the session[:previous], or if session[:previous] is bad
    back = build_url(session[:pre_previous]) if session[:pre_previous].present? && (params_match?(session[:previous], params) || bad_param?(session[:previous]))

    # @return_path is now available to all controllers and views
    @return_path = URI(back).to_s
  end

  def params_match?(param1, param2)
    return false if param1.blank? || param2.blank?

    return false if param1.as_json.size != param2.as_json.size

    param1.as_json == param2.as_json
  end

  def bad_param?(param)
    return true if param.blank?

    (Constants::Params::BAD_ACTIONS.include? param['action']) ||
      param['commit'].present? ||
      param['controller'] == 'sessions'
  end

  def build_url(param)
    return default_path if param.nil?

    # CLEAR out the old controller & action vars since url_for will append when nested
    # https://apidock.com/rails/ActionDispatch/Routing/UrlFor/url_for
    begin
      url_options[:_recall][:controller] = nil
      url_options[:_recall][:action] = nil
      url_for(param)
    rescue ActionController::UrlGenerationError
      default_path
    end
  end

  def default_path
    current_user.present? ? data_path : root_path
  end

  def url_params
    params.permit(:controller, :action, :year, :month, :id, :date, :tech, :sect)
  end
end
