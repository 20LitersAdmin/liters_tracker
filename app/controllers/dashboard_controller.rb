# frozen_string_literal: true

class DashboardController < ApplicationController
  layout 'dashboard', only: [:index]

  def index
    @lifetime_stats = Technology.report_worthy.map do |technology|
      next if technology.reports.distributions.empty?

      { stat: technology.lifetime_distributed, title: "#{technology.name}s" }
    end
    @global_impact = Report.distributions.sum(:impact)

    @future_plans = Plan.current.incomplete.any?

    # collect years for #year_nav
    @years = Report.with_stories.pluck(:year).uniq.sort.reverse

    # set default year and month
    @year = Date.today.year
    @month = Date.today.month

    # collect months for #month_nav based on @year
    @months = Report.with_stories.where(year: @year).pluck(:month).uniq.sort

    @stories = Story.joins(:report).where('reports.year = ?', @year)

    @title = 'See Our Progress'
    @subtitle = 'Our success stories are not rare. We\'re reaching communities, families, and individuals every day.<br />Every day we move more people towards water security and unleash the power that clean water brings.'.html_safe
  end

  def handler
    @year = params[:year].to_i

    @years = Report.with_stories.pluck(:year).uniq.sort.reverse
    @months = Report.with_stories.where(year: @year).pluck(:month).uniq.sort

    @future_plans = Plan.current.incomplete.any?

    @stories = if params[:month].present?
                 @month = params[:month].to_i
                 Story.joins(:report).where('reports.year = ? AND reports.month = ?', @year, @month)
               else
                 Story.joins(:report).where('reports.year = ?', @year)
               end

    respond_to do |format|
      format.js
    end
  end

  def planner
    @plans = Plan.current.incomplete.limit(20)

    respond_to do |format|
      format.js { render 'index', layout: false }
    end
  end
end
