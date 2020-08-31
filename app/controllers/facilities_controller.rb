# frozen_string_literal: true

class FacilitiesController < ApplicationController
  before_action :set_facility, only: %i[show edit update destroy reassign reassign_to]
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
    @districts = District.visible.order(:name)
    @sectors = [['Please select a District', '0']]
    @cells = [['Please select a Sector', '0']]
    @villages = [['Please select a Cell', '0']]
  end

  # GET /facilities/1/edit
  def edit
    @districts = District.visible.order(:name)
    @sectors = @facility.district.sectors
    @cells = @facility.sector.cells
    @villages = @facility.cell.villages

    @district = @facility.district
    @sector = @facility.sector
    @cell = @facility.cell
    @village = @facility.village

    @delete_message = 'Are you sure you want to DELETE this facility?'
    @delete_message += " This facility has #{view_context.pluralize(@facility.reports.size, 'report')} which will be deleted." if @facility.reports.any?
  end

  # POST /facilities
  # POST /facilities.json
  def create
    authorize @facility = Facility.new(facility_params)

    # params[:facility][:village] is coming through like "2", so it must be set separately
    # otherwise, I have to use :village_id which breaks the finders.coffee universal lookup.
    @facility.village_id = params[:facility][:village] unless facility_params[:village_id]

    respond_to do |format|
      if @facility.save
        format.html { redirect_to @return_path, notice: 'Facility created.' }
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
    authorize @facility

    # params[:facility][:village] is coming through like "2", so it must be set separately
    # otherwise, I have to use :village_id which breaks the finders.coffee universal lookup.
    @facility.assign_attributes(facility_params)
    @facility.village_id = params[:facility][:village] unless facility_params[:village_id]

    respond_to do |format|
      if @facility.save
        format.html { redirect_to @return_path, notice: 'Facility updated.' }
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
    redirect_to reassign_facility_path(@facility) and return if @facility.reports.any? || @facility.plans.any?

    # break the reassign / reassign_to loop
    @return_path = facilities_path if @return_path.include? 'reassign'

    authorize @facility.destroy
    respond_to do |format|
      format.html { redirect_to @return_path, notice: 'Facility destroyed.' }
      format.json { head :no_content }
    end
  end

  def reassign
    authorize @facility

    @reports = @facility.reports
    @plans = @facility.plans

    if @reports.any? || @plans.any?
      @facilities = @facility.similar_by_name.select(:name, :id, :hierarchy)
      render :reassign
    else
      render :can_be_deleted
    end
  end

  def reassign_to
    authorize @facility

    @to_facility = Facility.find(params[:to])

    @facility.reports.update_all(reportable_id: @to_facility.id) if @facility.reports.any?
    @facility.plans.update_all(planable_id: @to_facility.id) if @facility.plans.any?

    redirect_to reassign_facility_path(@facility)
  end

  private

  def set_facility
    authorize @facility = Facility.find(params[:id])
  end

  def set_sector_collection
    @sectors = Sector.visible.select(:name, :id).order(:name)
  end

  def facility_params
    params.require(:facility).permit(:name,
                                     :category,
                                     :description,
                                     :population,
                                     :households,
                                     :latitude,
                                     :longitude,
                                     :village_id)
  end
end
