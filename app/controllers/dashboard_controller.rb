# frozen_string_literal: true

class DashboardController < ApplicationController
  layout 'dashboard', only: %i[index]

  def index
    @lifetime_stats = Technology.dashboard_worthy.map do |technology|
      lifetime_stat = technology.lifetime_distributed
      next if lifetime_stat.zero?

      { stat: lifetime_stat, title: technology.plural_name }
    end
    @progress_date = Report.order(date: :desc).first&.date
    # @global_impact = Report.distributions.sum(:impact)
    @global_impact = Technology.all.map(&:lifetime_impact).sum

    @dates = Report.with_stories.pluck(:year, :month).uniq.sort.reverse

    # collect years for #year_nav
    @years = @dates.map { |ary| ary[0] }.uniq

    # set default year
    @year = @years.first

    # collect months for #month_nav based on @year
    @months = Report.with_stories.where(year: @year).pluck(:month).uniq.sort

    # set default month
    # @month = @months.last

    @stories = Story.joins(:report).where('reports.year = ?', @year).order('reports.date DESC')

    @title = 'See Our Progress'
    @subtitle = 'Our success stories are not rare. We\'re reaching communities, families, and individuals every day.<br />Every day we move more people towards water security and unleash the power that clean water brings.'.html_safe
  end

  def handler
    @year = params[:year].to_i

    @years = Report.with_stories.pluck(:year).uniq.sort.reverse
    @months = Report.with_stories.where(year: @year).pluck(:month).uniq.sort

    @stories = if params[:month].present?
                 @month = params[:month].to_i
                 Story.joins(:report).where('reports.year = ? AND reports.month = ?', @year, @month).order('reports.date DESC')
               else
                 Story.joins(:report).where('reports.year = ?', @year).order('reports.date DESC')
               end

    respond_to do |format|
      format.js { render 'handler', layout: false }
    end
  end

  def planner
    @plans = Plan.current.incomplete.limit(20)

    respond_to do |format|
      format.js { render 'index', layout: false }
    end
  end

  def stats_json
    lifetime_stats = []
    Technology.dashboard_worthy.map do |technology|
      lifetime_stat = technology.lifetime_distributed
      next if lifetime_stat.zero?

      lifetime_stats << { stat: lifetime_stat.to_i, title: technology.plural_name }
    end

    lifetime_stats << { stat: Technology.all.map(&:lifetime_impact).sum, title: 'People served' }
    lifetime_stats << { as_of_date: Report.order(date: :desc).first.date }

    render json: lifetime_stats
  end
end
