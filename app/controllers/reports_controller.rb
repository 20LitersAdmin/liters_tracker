# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[show edit update destroy]

  # GET /reports
  # GET /reports.json
  def index
    authorize @reports = Report.all
  end

  # GET /reports/1
  # GET /reports/1.json
  def show
  end

  # GET /reports/new
  def new
    authorize @report = Report.new
  end

  # GET /reports/1/edit
  def edit
  end

  # POST /reports
  # POST /reports.json
  def create
    authorize @report = Report.new(report_params)

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /reports/1
  # PATCH/PUT /reports/1.json
  def update
    respond_to do |format|
      if @report.update(report_params)
        format.html { redirect_to @report, notice: 'Report was successfully edited.' }
        format.json { render :show, status: :ok, location: @report }
      else
        format.html { render :edit }
        format.json { render json: @report.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reports/1
  # DELETE /reports/1.json
  def destroy
    @report.destroy
    respond_to do |format|
      format.html { redirect_to reports_url, notice: 'Report was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def batch_process
    authorize current_user

    if Report.key_params_are_missing?(batch_report_params)
      flash[:error] = 'Oops, some data got lost. Please try again'
    else
      Report.batch_process(batch_report_params, current_user.id)
      flash[:success] = 'The report was successfully submitted.'
    end

    redirect_to select_sectors_path
  end

  private

  def set_report
    authorize @report = Report.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:date, :technology_id, :distributed, :checked, :user_id, :model_gid, :distribute, :checked, :people, :households, :reportable_id, :reportable_type)
  end

  def batch_report_params
    params.require(:batch_reports).permit(:technology_id, :contract_id, reports: %i[date technology_id model_gid distributed checked people households reportable_id reportable_type])
  end
end
