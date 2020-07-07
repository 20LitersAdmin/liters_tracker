# frozen_string_literal: true

module ApplicationHelper
  def bootstrap_class_for(flash_type)
    Constants::Application::BOOTSTRAP_CLASSES[flash_type.to_sym] || flash_type.to_s
  end

  def format_hierarchy(array_of_hashes, slim: false, links: false)
    str = ''

    array_of_hashes.each do |geo|
      geo.symbolize_keys!

      next if slim && geo[:parent_type] == 'Country'

      geo_name = slim ? geo[:parent_name] : "#{geo[:parent_name]} #{geo[:parent_type]}"
      str += links ? link_to(geo_name, geo[:link]) : geo_name
      str += ' > ' unless geo == array_of_hashes.last
    end

    str.html_safe
  end

  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def human_date(date)
    return '-' if date.nil?

    date&.strftime('%b %-d, %Y')
  end

  def human_datetime(datetime)
    datetime&.strftime('%-m/%-d @ %l:%M:%S %p %Z')
  end

  def human_number(number)
    return '-' if number.nil? || number.zero?

    number_with_delimiter(number, delimiter: ',')
  end

  def form_date(date)
    date&.strftime('%Y-%m-%d')
  end

  def form_datetime(datetime)
    datetime&.strftime('%Y-%m-%dT%H:%M')
  end

  def flash_messages(_opts = {})
    flash.each do |msg_type, message|
      concat(
        content_tag(:div, message, class: "alert alert-#{bootstrap_class_for(msg_type)} alert-dismissable fade show", role: 'alert') do
          concat content_tag(:button, 'x', class: 'close', data: { dismiss: 'alert' })
          concat message
        end
      )
    end
    nil
  end

  def monthly_date(monthly)
    Date.new(monthly.year, monthly.month, 1).strftime('%m/%Y')
  end

  def apple_touch_icon(dimension)
    s = "#{dimension}x#{dimension}"
    url = "https://20liters.org/wp-content/themes/twenty-liters/library/images/icons/apple-touch-icon-#{s}.png"
    "<link rel='apple-touch-icon-precomposed' sizes='#{s}' href='#{url}'>".html_safe
  end

  def favicon(dimension)
    s = "#{dimension}x#{dimension}"
    url = "https://20liters.org/wp-content/themes/twenty-liters/library/images/icons/favicon-#{s}.png"
    "<link rel='icon' type='image/png' sizes='#{s}' href='#{url}'>".html_safe
  end
end
