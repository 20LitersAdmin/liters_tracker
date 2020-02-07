# frozen_string_literal: true

class MonthlyController < ApplicationController
  def index
    authorize @monthly = Monthly.new
    @years = (Report.earliest_date.strftime('%Y').to_i..Report.latest_date.strftime('%Y').to_i).to_a
    @months = Date::MONTHNAMES.compact.each_with_index.collect { |m, i| [m, i + 1] }

    date = Report.latest_date
    @year = date.year
    @month = date.month
  end

  def redirector
    authorize @monthly = Monthly.new(monthly_params)

    if @monthly.valid?
      redirect_to monthly_w_date_path(year: @monthly.year, month: @monthly.month)
    else
      render :index
    end
  end

  def show
    authorize monthly = Monthly.new(slim_params)
    @technologies = Technology.report_worthy.order(scale: :desc, id: :asc)

    @date = Date.new(monthly.year, monthly.month, 1)
    @reports = Report.within_month(@date)
    @stories = Story.where(report_id: @reports.pluck(:id).uniq)

    @previous = Monthly.new(year: @date.last_month.year, month: @date.last_month.month) if Report.within_month(@date.last_month).any?
    @next = Monthly.new(year: @date.next_month.year, month: @date.next_month.month) if Report.within_month(@date.next_month).any?
    console
  end

  private

  def monthly_params
    params.require(:monthly).permit(:year, :month)
  end

  def slim_params
    params.permit(:year, :month)
  end
end
