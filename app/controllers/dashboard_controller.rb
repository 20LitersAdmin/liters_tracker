# frozen_string_literal: true

class DashboardController < ApplicationController
  layout 'dashboard'

  def index
    @lifetime_stats = Technology.report_worthy.map do |technology|
      next if technology.lifetime_impact.zero?

      { stat: technology.lifetime_impact, title: "#{technology.name}s" }
    end

    @global_impact = Report.all.sum(:people)
    @stories = Story.get_stories_by_year(Time.now.year.to_s)
  end

  def year_handler
    @stories = Story.get_stories_by_year(params["year"]) 
    respond_to do |format|
      format.js
    end
  end
end
