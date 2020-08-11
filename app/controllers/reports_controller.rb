# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[show edit update destroy]

  def index; end

  def show; end

  def dttb_index
    authorize @reports = Report.includes(:technology).includes(:user).order(date: :desc)

    respond_to do |format|
      format.html
      format.json { render 'index.json' }
    end
  end

  def edit
    @technologies = Technology.report_worthy.pluck(:name, :id)

    @geography = @report.reportable
  end

  def create
    # Sectors#report forms submit to this action as AJAX
    # check for duplicates first
    authorize @report = Report.where(dup_matching_params).first_or_initialize

    @report.assign_attributes(report_params)
    @report.user = current_user

    @persistence = @report.new_record? ? 'Report created.' : 'A matching report was found and updated.'

    respond_to do |format|
      if @report.save
        format.html do
          flash[:success] = @persistence
          redirect_to @return_path
        end
        format.json { render :show, status: :created, location: @report }
        format.js do
          @technology = @report.technology
          @reports = @report.reportable.sector.related_reports.where(technology: @technology).between(@report.date.beginning_of_month, @report.date.end_of_month)
          @partial = "sectors/#{@technology.type}_reports"
          render :report_created
        end
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
        format.js { render :report_error }
      end
    end
  end

  def update
    @report.user = current_user

    respond_to do |format|
      if @report.update(report_params)
        format.html do
          flash[:success] = 'Report edited.'
          redirect_to @return_path
        end
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit }
        format.json { render json: @report.errors, status: :unprocessable_entity }
        format.js { render :report_error }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    authorize @report.destroy

    respond_to do |format|
      format.html do
        flash[:notice] = 'Report deleted.'
        redirect_to @return_path
      end
      format.json { head :no_content }
      format.js { render :report_destroyed }
    end
  end

  private

  def set_report
    authorize @report = Report.find(params[:id])
  end

  def report_params
    # user_id is set in ReportsController#create and ReportsController#update
    # contract_id is set in Report#set_contract_from_date
    # impact is set in Report#calculate_impact
    # year and month are set in Report#set_year_and_month_from_date
    params.require(:report).permit(:date,
                                   :technology_id,
                                   :reportable_id,
                                   :reportable_type,
                                   :distributed,
                                   :checked,
                                   :people,
                                   :hours)
  end

  def dup_matching_params
    params.require(:report).permit(:date,
                                   :technology_id,
                                   :reportable_id,
                                   :reportable_type)
  end
end
