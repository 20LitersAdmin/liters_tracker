# frozen_string_literal: true

class SectorsController < ApplicationController
  before_action :set_sector, only: %w[show edit update destroy]

  # GET /sectors
  # GET /sectors.json
  def index
    authorize @sectors = Sector.all.order(:name)

    @earliest = form_date Report.earliest_date
    @latest =   form_date Report.latest_date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to =   params[:to].present? ? Date.parse(params[:to]) : @latest

    @reports = Report.where(date: @from..@to).order(date: :asc)
    @plans = Plan.between(@from, @to)

    @plan_date = human_date @plans.size.zero? ? nil : Contract.find(@plans.pluck(:contract_id).max).end_date
  end

  def select
    authorize @sectors = Sector.all.order(:name)
  end

  def report
    @cells = @sector.cells
    @facilities_sam2 = @sector.facilities.not_churches.order(:name)
    @facilities_rwhs = @sector.facilities.churches.order(:name)
  end

  # GET /sectors/1
  # GET /sectors/1.json
  def show
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

    @reports = Report.where(date: @from..@to).related_to_sector(@sector).order(date: :asc)
    @technologies = Technology.report_worthy
    @plans = Plan.related_to_sector(@sector)
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
  # POST /sectors.json
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
  # PATCH/PUT /sectors/1.json
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
  # DELETE /sectors/1.json
  def destroy
    authorize @sector.destroy
    respond_to do |format|
      format.html { redirect_to sectors_url, notice: 'Sector was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_sector
    authorize @sector = Sector.find(params[:id])
  end

  def sector_params
    params.require(:sector).permit(:name, :gis_id, :latitude, :longitude, :population, :households)
  end

  def report_params
    params.require(:reports).permit(:all)
  end
end
