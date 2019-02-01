# frozen_string_literal: true

class FacilitiesController < ApplicationController
  before_action :set_facility, only: [:show, :edit, :update, :destroy]

  # GET /facilities
  # GET /facilities.json
  def index
    authorize @facilities = Facility.all
  end

  # GET /facilities/1
  # GET /facilities/1.json
  def show
  end

  # GET /facilities/new
  def new
    authorize @facility = Facility.new
    @sectors = Sector.all.select(:name, :id).order(:name)
  end

  # GET /facilities/1/edit
  def edit
  end

  # POST /facilities
  # POST /facilities.json
  def create
    authorize @facility = Facility.new(facility_params)

    byebug

    if @facility.save
      flash[:success] = 'Facility was successfully created.'
      redirect_to root_path
    else
      @sectors = Sector.all.select(:name, :id).order(:name)
      render :new
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

  def village_finder
    authorize @sector = Sector.find(params[:sector])

    villages = @sector.villages.select(:id, :name).order(:name)

    render json: villages
  end

  private

  def set_facility
    authorize @facility = Facility.find(params[:id])
  end

  def facility_params
    params.require(:facility).permit(:name, :category, :description, :village_id, :population, :households, :latitude, :longitude)
  end
end
