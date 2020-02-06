# frozen_string_literal: true

class ReportsController < ApplicationController
  before_action :set_report, only: %i[show edit update destroy]

  # GET /reports
  # GET /reports.json
  def index
    authorize @reports = Report.order(date: :desc).paginate(page: params[:page], per_page: params[:per_page] || 20)
  end

  # GET /reports/1
  # GET /reports/1.json
  def show; end

  # GET /reports/new
  def new
    authorize @report = Report.new
  end

  # GET /reports/1/edit
  def edit; end

  # POST /reports
  # POST /reports.json
  def create
    authorize @report = Report.new(report_params)
    @report.user = current_user

    # check for duplicates first
    # destroy the original and replace with this record if duplicate exists
    # does Report.where(report_params).first_or_initialize work?

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
        format.js do
          @reports = @report.reportable.sector.related_reports.where(technology: @report.technology, date: @report.date)
          render :report_created
        end
      else
        format.html { render :new }
        format.json { render json: @report.errors, status: :unprocessable_entity }
        format.js { render :report_error }
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
        format.js { render :report_error }
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
      # TODO: flash[:notice] = 'Report was successfully destroyed.'
      format.js { render :report_destroyed }
    end
  end

  private

  def set_report
    authorize @report = Report.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:date,
                                   :technology_id,
                                   :distributed,
                                   :checked,
                                   :user_id,
                                   :people,
                                   :reportable_id,
                                   :reportable_type)
  end
end
