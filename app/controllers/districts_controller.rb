# frozen_string_literal: true

class DistrictsController < ApplicationController
  before_action :set_district, only: %i[show edit update destroy]

  # GET /districts
  def index
    authorize @districts = District.all

    @dist_ids = @districts.pluck(:id)

    @earliest = form_date Report.earliest_date
    @latest =   form_date Report.latest_date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to =   params[:to].present? ? Date.parse(params[:to]) : @latest

    @reports = Report.where(date: @from..@to).order(date: :asc)
    @plans = Plan.between(@from, @to)

    @plan_date = human_date @plans.last&.contract&.end_date
  end

  # GET /districts/1
  def show
    @reports = Report.related_to(@district)

    @skip_blanks = params[:skip_blanks].present?
    @skip_blanks_rfp = request.fullpath.include?('?') ? request.fullpath + '&skip_blanks=true' : request.fullpath + '?skip_blanks=true'

    @by_mou = params[:by_mou].present?
    @by_mou_rfp = request.fullpath.include?('?') ? request.fullpath + '&by_mou=true' : request.fullpath + '?by_mou=true'

    @view_btn_text = @by_mou ? 'View by Sector' : 'View by MOU'
    @searchbar_hidden_fields = @by_mou ? [{ name: 'by_mou', value: 'true' }] : []
    @searchbar_hidden_fields << { name: 'skip_blanks', value: 'true' } if @skip_blanks
    @contract_search_param_add = @by_mou ? '&by_mou=true' : ''
    @contract_search_param_add += @skip_blanks ? '&skip_blanks=true' : ''

    if @by_mou
      @mous = Contract.between(@from, @to).order(start_date: :asc)
      @targets = Target.where(contract: @mous).where(technology: @technology)
    else
      @sectors = @district.sectors
      @plans = Plan.related_to(@district)
      @plan_date = human_date @plans.last&.contract&.end_date
    end
  end

  # GET /districts/new
  def new
    authorize @district = District.new
  end

  # GET /districts/1/edit
  def edit
  end

  # POST /districts
  def create
    authorize @district = District.new(district_params)

    respond_to do |format|
      if @district.save
        format.html { redirect_to @district, notice: 'District was successfully created.' }
        format.json { render :show, status: :created, location: @district }
      else
        format.html { render :new }
        format.json { render json: @district.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /districts/1
  def update
    respond_to do |format|
      if @district.update(district_params)
        format.html { redirect_to @district, notice: 'District was successfully updated.' }
        format.json { render :show, status: :ok, location: @district }
      else
        format.html { render :edit }
        format.json { render json: @district.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /districts/1
  def destroy
    @district.destroy
    respond_to do |format|
      format.html { redirect_to districts_url, notice: 'District was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_district
    authorize @district = District.find(params[:id])
  end

  def district_params
    params.require(:district).permit(:name, :gis_id, :latitude, :longitude, :population, :households)
  end
end
