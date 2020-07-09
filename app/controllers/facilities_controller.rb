# frozen_string_literal: true

class FacilitiesController < ApplicationController
  before_action :set_facility, only: %i[show edit update destroy]
  before_action :set_sector_collection, only: %i[new edit update create]

  # GET /facilities
  # GET /facilities.json
  def index
    authorize @facilities = Facility.all.order(name: :asc)
  end

  # GET /facilities/1
  # GET /facilities/1.json
  def show
    @earliest = form_date Report.earliest_date
    @latest =   form_date Report.latest_date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to =   params[:to].present? ? Date.parse(params[:to]) : @latest

    @skip_blanks = params[:skip_blanks].present?
    @skip_blanks_rfp = request.fullpath.include?('?') ? request.fullpath + '&skip_blanks=true' : request.fullpath + '?skip_blanks=true'

    @searchbar_hidden_fields = @skip_blanks ? [{ name: 'skip_blanks', value: 'true' }] : []
    @contract_search_param_add = @skip_blanks ? '&skip_blanks=true' : ''

    @reports = @facility.reports.between(@from, @to)
    @plans = @facility.plans.between(@from, @to)
    @technologies = Technology.report_worthy
    @plan_date = human_date @plans.size.zero? ? nil : Contract.find(@plans.pluck(:contract_id).max).end_date
  end

  # GET /facilities/new
  def new
    authorize @facility = Facility.new

    # "blank" geographies for selected values on select fields
    @district = District.new
    @sector = Sector.new
    @cell = Cell.new
    @village = Village.new

    # default collections
    @districts = District.order(:name)
    @sectors = [['Please select a District', '0']]
    @cells = [['Please select a Sector', '0']]
    @villages = [['Please select a Cell', '0']]
    @facilities = [['Please select a Village', '0']]
  end

  # GET /facilities/1/edit
  def edit; end

  # POST /facilities
  # POST /facilities.json
  def create
    authorize @facility = Facility.new(facility_params)

    # params[:facility][:village] is coming through like "2", so it must be set separately
    # otherwise, I have to use :village_id on all the forms and that's annoying.
    @facility.village = Village.find(params[:facility][:village]) if params[:facility][:village].present?

    respond_to do |format|
      if @facility.save
        format.html { redirect_to @return_path, success: 'Facility was successfully created.' }
        format.js { render :facility_created }
      else
        # pre-populate select fields on error using current planable
        @district = @facility.district
        @sector = @facility.sector
        @cell = @facility.cell
        @village = @facility.village

        # default collections
        @districts = District.order(:name).pluck(:name, :id)
        @sectors = @facility.sectors&.pluck(:name, :id)
        @cells = @facility.cells&.pluck(:name, :id)
        @villages = @facility.villages&.pluck(:name, :id)

        format.html { render :new }
        format.js { render :facility_error }
      end
    end
  end

  # PATCH/PUT /facilities/1
  # PATCH/PUT /facilities/1.json
  def update
    respond_to do |format|
      if @facility.update(facility_params)
        format.html { redirect_to @facility, notice: 'Facility was successfully updated.' }
        format.json { render :show, status: :ok, location: @facility }
      else
        format.html { render :edit }
        format.json { render json: @facility.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /facilities/1
  # DELETE /facilities/1.json
  def destroy
    authorize @facility.destroy
    respond_to do |format|
      format.html { redirect_to facilities_url, notice: 'Facility was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_facility
    authorize @facility = Facility.find(params[:id])
  end

  def set_sector_collection
    @sectors = Sector.all.select(:name, :id).order(:name)
  end

  def facility_params
    # village is not included in params, is set separately in the create / update actions
    params.require(:facility).permit(:name, :category, :description, :population, :households, :latitude, :longitude)
  end
end
