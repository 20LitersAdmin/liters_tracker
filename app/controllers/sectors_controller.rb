# frozen_string_literal: true

class SectorsController < ApplicationController
  before_action :set_sector, only: %w[show edit update destroy report children make_visible]

  # GET /sectors
  def index
    authorize @sectors = Sector.visible.order(:name)

    @show_hidden = Sector.hidden.any?

    @earliest = form_date Report.earliest_date
    @latest =   form_date Report.latest_date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to =   params[:to].present? ? Date.parse(params[:to]) : @latest
  end

  def hidden
    authorize @sectors = Sector.hidden.includes(:district).select(:id, :name, :district_id).order(:name)
    @show_visible = Sector.visible.any?
  end

  def select
    authorize @sectors = Sector.visible.order(:name)
    @technologies = Technology.report_worthy.order(:short_name)

    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today.beginning_of_month - 1.month
    @earliest_year = Report.earliest_date.year
  end

  def report
    begin
      @technology = Technology.find(params[:tech])
    rescue ActiveRecord::RecordNotFound
      flash[:alert] = 'Oops, lost the technology selection somehow. Please try again.'
      redirect_to select_sectors_path and return
    end

    @date = params[:date].present? ? Date.parse(params[:date]) : Date.today.beginning_of_month - 1.month

    @plans = @sector.related_plans.where(technology: @technology).nearest_to_date(@date)

    @reports = @sector.related_reports.where(technology: @technology).between(@date.beginning_of_month, @date.end_of_month)

    @report = Report.new(technology: @technology)
    @report.date = @date if @technology.scale == 'Family'

    @cells = @sector.cells.order(:name).pluck(:name, :id)
    @cell = Cell.new
    @villages = [['Please select a Cell', '0']]
    @village = Village.new

    return unless @technology.scale == 'Community'

    @facility = Facility.new
    @facilities = [['Please select a Village', '0']]
  end

  # GET /sectors/1
  def show
    if @sector.hidden?
      flash[:error] = "This sector is currently hidden. Please #{view_context.link_to('edit', edit_sector_path(@sector)).html_safe} the record to make it visible."
      flash[:html_safe] = true
    end

    @earliest = form_date Report.earliest_date
    @latest =   form_date Report.latest_date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to =   params[:to].present? ? Date.parse(params[:to]) : @latest

    @skip_blanks = params[:skip_blanks].present?
    @skip_blanks_rfp = request.fullpath.include?('?') ? request.fullpath + '&skip_blanks=true' : request.fullpath + '?skip_blanks=true'

    @by_tech = params[:by_tech].present?
    @by_tech_rfp = request.fullpath.include?('?') ? request.fullpath + '&by_tech=true' : request.fullpath + '?by_tech=true'

    @searchbar_hidden_fields = @by_tech ? [{ name: 'by_tech', value: 'true' }] : []
    @searchbar_hidden_fields << { name: 'skip_blanks', value: 'true' } if @skip_blanks
    @contract_search_param_add = @by_tech ? '&by_tech=true' : ''
    @contract_search_param_add += @skip_blanks ? '&skip_blanks=true' : ''

    @reports = @sector.related_reports.between(@from, @to)
    @plans = @sector.related_plans.between(@from, @to)
    @technologies = Technology.report_worthy
    @plan_date = human_date @plans.size.zero? ? nil : Contract.find(@plans.pluck(:contract_id).max).end_date
    @cells = @sector.cells.order(name: :asc)
  end

  # GET /sectors/new
  def new
    authorize @sector = Sector.new
  end

  # GET /sectors/1/edit
  def edit
  end

  # POST /sectors
  def create
    authorize @sector = Sector.new(sector_params)

    respond_to do |format|
      if @sector.save
        format.html { redirect_to @sector, notice: 'Sector was successfully created.' }
        format.json { render :show, status: :created, location: @sector }
      else
        format.html { render :new }
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sectors/1
  def update
    respond_to do |format|
      if @sector.update(sector_params)
        format.html { redirect_to @sector, notice: 'Sector was successfully updated.' }
        format.json { render :show, status: :ok, location: @sector }
      else
        format.html { render :edit }
        format.json { render json: @sector.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sectors/1
  def destroy
    authorize @sector.destroy
    respond_to do |format|
      format.html { redirect_to sectors_url, notice: 'Sector was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  ## facilities#_form ajax
  ## plans#_form ajax
  ## sectors#report ajax
  def children
    render json: @sector.cells.select(:id, :name).order(:name)
  end

  def make_visible
    @sector.update(hidden: false)

    redirect_to sectors_path
  end

  private

  def set_sector
    authorize @sector = Sector.find(params[:id])
  end

  def sector_params
    params.require(:sector).permit(:name,
                                   :gis_code,
                                   :latitude,
                                   :longitude,
                                   :population,
                                   :households,
                                   :hidden)
  end
end
