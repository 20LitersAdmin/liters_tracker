# frozen_string_literal: true

class DashboardController < ApplicationController
  layout 'dashboard'

  def index
    @lifetime_stats = Technology.report_worthy.map do |technology|
      next if technology.lifetime_impact.zero?

      { stat: technology.lifetime_impact, title: "#{technology.name}s" }
    end

    @dates = Story.array_of_unique_dates

    @years = @dates.map(&:year).uniq.sort.reverse

    @year = Date.today.year
    if @year
      @months, @stories = Story.bin_stories_by_year(@year)
    else
      @months = []
    end

    @global_impact = Report.all.sum(:people)

    @story_month_hash  = Story.bin_stories_by_year(Date.today.year)
    
  end

  def handler
    
    @year = params[:year].to_i
    @months, @stories = Story.bin_stories_by_year(@year)

    month = Date.const_get(:ABBR_MONTHNAMES).index(params[:month])
  
    if params[:month]
      @stories = @stories.select{|story| story.report.date.month == month }
    end
  
    respond_to do |format|
      format.js
    end
  end

  def planner
    @plans = Plan.current.incomplete.limit(20)

    respond_to do |format|
      format.js
    end
  end
end
