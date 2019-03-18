# frozen_string_literal: true

class MonthlyController < ApplicationController
  def index
    authorize @monthly = Monthly.new
    @years = (Report.earliest_date.strftime('%Y').to_i..Report.latest_date.strftime('%Y').to_i).to_a
    @months = Date::MONTHNAMES.compact.each_with_index.collect { |m, i| [m, i + 1] }
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
    @date = Date.new(monthly.year, monthly.month, 1)

    @reports = Report.within_month(@date)
    @sectors = Sector.where(id: @reports.map { |r| r.model.sector.id }.uniq)
    @cells = Cell.where(id: @reports.map { |r| r.model.cell.id }.uniq)
    @villages = Village.where(id: @reports.map { |r| r.model.village.id }.uniq)
    @technologies = Technology.report_worthy.order(scale: :desc, id: :asc)
  end

  private

  def monthly_params
    params.require(:monthly).permit(:year, :month)
  end

  def slim_params
    params.permit(:year, :month)
  end
end
