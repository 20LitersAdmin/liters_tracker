# frozen_string_literal: true

require 'datatables/report_datatable'

class ReportsController < ApplicationController
  before_action :set_report, only: %i[show edit update destroy]
  before_action :datatable_params, only: [:datatable]

  def index; end

  def show; end

  def datatable
    respond_to do |format|
      format.html
      format.json { render json: Datatables::ReportDatatable.new(params) }
    end
  end

  def edit
    @technologies = Technology.report_worthy.pluck(:name, :id)

    @geography = @report.reportable
  end

  def create
    # Sectors#report forms submit to this action as AJAX
    # check for duplicates first
    set_params(reportable_params)

    authorize @report = Report.where(@dup_matching_params).first_or_initialize

    @report.assign_attributes(@remaining_params)
    @report.user = current_user

    @persistence = @report.new_record? ? 'Report created.' : 'A matching report was found and updated.'

    respond_to do |format|
      if @report.save
        format.html { redirect_to @return_path, notice: @persistence }
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
        format.html { redirect_to @return_path, notice: 'Report edited.' }
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
      format.html { redirect_to @return_path, notice: 'Report deleted.' }
      format.json { head :no_content }
      format.js { render :report_destroyed }
    end
  end

  def params
    @_dt_params || super
  end

  private

  def set_report
    authorize @report = Report.find(params[:id])
  end

  def datatable_params
    @_dt_params = request.parameters
    def @_dt_params.permit(*args)
      self
    end
    @_dt_params
  end

  def set_params(params)
    # TODO: could use improvement
    # types = Constants::Geography::HIERARCHY.reverse.map(&:downcase)
    case
    when params[:facility]
      reportable_type = 'Facility'
      reportable_id = params[:facility].to_i
    when params[:village]
      reportable_type = 'Village'
      reportable_id = params[:village].to_i
    when params[:cell]
      reportable_type = 'Cell'
      reportable_id = params[:cell].to_i
    when params[:sector]
      reportable_type = 'Sector'
      reportable_id = params[:sector].to_i
    end

    @dup_matching_params = ActionController::Parameters.new({
      date:            report_params[:date],
      technology_id:   report_params[:technology_id],
      reportable_type: reportable_type,
      reportable_id:   reportable_id
    }).permit!

    @remaining_params = ActionController::Parameters.new({
      distributed: report_params[:distributed],
      checked:     report_params[:checked],
      people:      report_params[:people],
      hours:       report_params[:hours]
    }).permit!
  end

  def report_params
    # user_id is set in ReportsController#create and ReportsController#update
    # contract_id is set in Report#set_contract_from_date
    # impact is set in Report#calculate_impact
    # year and month are set in Report#set_year_and_month_from_date
    params.require(:report).permit(:date,
                                   :technology_id,
                                   :distributed,
                                   :checked,
                                   :people,
                                   :hours)
  end

  def reportable_params
    # these params are used to determine reportable_id and reportable_type via ApplicationHelper#set_polymorphic_from_params
    params.require(:report).permit(:district,
                                   :sector,
                                   :cell,
                                   :village,
                                   :facility)
  end
end
