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
  def edit
    @technologies = Technology.report_worthy.pluck(:name, :id)

    @geography = @report.reportable
    @parent = @geography.parent
    @hierarchy = ["#{@parent.name} #{@parent.class}"]
    @grandparent = @parent.parent
    @hierarchy << "#{@grandparent.name} #{@grandparent.class}" if @grandparent
    @great_grandparent = @grandparent.parent
    @hierarchy << "#{@great_grandparent.name} #{@great_grandparent.class}" if @great_grandparent

    @return_to = URI(request.referrer).request_uri || data_path
  end

  # POST /reports
  # POST /reports.json
  def create
    # check for duplicates first
    authorize @report = Report.where(dup_matching_params).first_or_initialize

    @report.assign_attributes(report_params)
    @report.user = current_user

    @persistence = @report.new_record? ? 'Report was successfully created.' : 'A matching report was found and updated.'

    respond_to do |format|
      if @report.save
        format.html { redirect_to @report, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @report }
        format.js do
          @reports = @report.reportable.sector.related_reports.where(technology: @report.technology).between(@report.date.beginning_of_month, @report.date.end_of_month)
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
    @report.user = current_user

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

    @redirect = params[:rt].present? ? params[:rt] : reports_path

    respond_to do |format|
      format.html { redirect_to @redirect, notice: 'Report was successfully destroyed.' }
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
