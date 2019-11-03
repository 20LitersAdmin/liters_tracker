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

    @global_impact = Report.all.sum(:people)

    @stories = Story.between_dates(Date.today.beginning_of_year, Date.today.end_of_year)
  end

  def handler
    # handle params[:year] vs params[:year] and params[:month]
    start_date = Date.new(params[:year].to_i,01,01)
    end_date = Date.new(params[:year].to_i,12,31)
    @stories = Story.between_dates(start_date,end_date)

    respond_to do |format|
      format.js
    end
  end
end
