# frozen_string_literal: true

class DashboardController < ApplicationController
  layout 'dashboard'

  def index
    @lifetime_stats = Technology.report_worthy.map do |technology|
      next if technology.lifetime_impact.zero?

      { stat: technology.lifetime_impact, title: "#{technology.name}s" }
    end

    @global_impact = Report.all.sum(:people)
    @stories = Story.all
  end

  def year_handler
    year = params["year"]
    
  end
end
