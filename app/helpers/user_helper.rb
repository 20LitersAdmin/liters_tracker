# frozen_string_literal: true

module UserHelper

  def translate_to_booleans(user_permissions_params)
    new_ary = {}
    user_permissions_params.to_h.deep_symbolize_keys.each do |set|
      new_ary << { set }
    end
  end

  def all_global_permissions?(user_permissions_params)
    user_permissions_params[:global_permissions][:all].to_i.positive? ||
      (
        user_permissions_params[:global_permissions][:create].to_i.positive? &&
        user_permissions_params[:global_permissions][:read].to_i.positive? &&
        user_permissions_params[:global_permissions][:update].to_i.positive? &&
        user_permissions_params[:global_permissions][:delete].to_i.positive?
      ) ||
      (
        user_permissions_params[:geo_permissions][:all].to_i.positive? &&
        user_permissions_params[:info_permissions][:all].to_i.positive?
      )
  end

  def any_global_permissions?(user_permissions_params)
    return false if user_permissions_params.blank?

    user_permissions_params[:global_permissions][:all].to_i.positive? ||
      user_permissions_params[:global_permissions][:create].to_i.positive? ||
      user_permissions_params[:global_permissions][:read].to_i.positive? ||
      user_permissions_params[:global_permissions][:update].to_i.positive? ||
      user_permissions_params[:global_permissions][:delete].to_i.positive?
  end

  def any_geo_permissions?(user_permissions_params)
    return false if user_permissions_params.blank?

    user_permissions_params[:geo_permissions][:all].to_i.positive? ||
      user_permissions_params[:geo_permissions][:create].to_i.positive? ||
      user_permissions_params[:geo_permissions][:read].to_i.positive? ||
      user_permissions_params[:geo_permissions][:update].to_i.positive? ||
      user_permissions_params[:geo_permissions][:delete].to_i.positive?
  end

  def any_info_permissions?(user_permissions_params)
    return false if user_permissions_params.blank?

    user_permissions_params[:info_permissions][:all].to_i.positive? ||
      user_permissions_params[:info_permissions][:create].to_i.positive? ||
      user_permissions_params[:info_permissions][:read].to_i.positive? ||
      user_permissions_params[:info_permissions][:update].to_i.positive? ||
      user_permissions_params[:info_permissions][:delete].to_i.positive?
  end
end
