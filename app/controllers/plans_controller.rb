# frozen_string_literal: true

class PlansController < ApplicationController
  before_action :set_plan, only: %i[edit update destroy]
  before_action :set_contract, only: %i[edit new create dttb_index]

  def dttb_index
    authorize @plans = @contract.plans.includes(:technology).order(date: :asc)

    respond_to do |format|
      format.html
      format.json { render 'index.json' }
    end
  end

  # GET /plans/1
  # GET /plans/1.json
  def show
  end

  # GET /plans/new
  def new
    authorize @plan = Plan.new

    @technologies = Technology.report_worthy.pluck(:name, :id)
    @min_date = @contract.start_date
    @max_date = @contract.end_date

    # "blank" geographies for selected values on select fields
    @district = District.new
    @sector = Sector.new
    @cell = Cell.new
    @village = Village.new
    @facility = Facility.new

    # default collections
    @districts = District.order(:name)
    @sectors = [['Please select a District', '0']]
    @cells = [['Please select a Sector', '0']]
    @villages = [['Please select a Cell', '0']]
    @facilities = [['Please select a Village', '0']]
  end

  # GET /plans/1/edit
  def edit
    @technologies = Technology.report_worthy.pluck(:name, :id)
    @min_date = @contract.start_date
    @max_date = @contract.end_date
  end

  # POST /plans
  # POST /plans.json
  def create
    # check for duplicates!!
    authorize @plan = Plan.new(plan_params)

    respond_to do |format|
      if @plan.save
        format.html { redirect_to @plan, notice: 'Plan was successfully created.' }
        format.json { render :show, status: :created, location: @plan }
      else
        @technologies = Technology.report_worthy.pluck(:name, :id)
        @min_date = @contract.start_date
        @max_date = @contract.end_date

        # pre-populate select fields on error using current planable
        @location = @plan.planable
        @district = @location.district
        @sector = @location.sector
        @cell = @location.cell
        @village = @location.village
        @facility = @location.facility

        # default collections
        @districts = District.order(:name).pluck(:name, :id)
        @sectors = @location.sectors&.pluck(:name, :id)
        @cells = @location.cells&.pluck(:name, :id)
        @villages = @location.villages&.pluck(:name, :id)
        @facilities = @location.facilities&.pluck(:name, :id)

        format.html { render :new }
        format.json { render json: @plan.errors, status: :unprocessable_entity }

        console
      end
    end
  end

  # PATCH/PUT /plans/1
  # PATCH/PUT /plans/1.json
  def update
    respond_to do |format|
      if @plan.update(plan_params)
        format.html { redirect_to @plan, notice: 'Plan was successfully updated.' }
        format.json { render :show, status: :ok, location: @plan }
      else
        format.html { render :edit }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plans/1
  # DELETE /plans/1.json
  def destroy
    authorize @plan.destroy
    respond_to do |format|
      format.html { redirect_to plans_url, notice: 'Plan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_plan
    authorize @plan = Plan.find(params[:id])
  end

  def set_contract
    @contract = Contract.find(params[:contract_id])
  end

  def plan_params
    params.require(:plan).permit(:contract_id,
                                 :technology_id,
                                 :goal,
                                 :people_goal,
                                 :planable_type,
                                 :planable_id,
                                 :date)
  end
end
