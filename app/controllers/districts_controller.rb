# frozen_string_literal: true

class DistrictsController < ApplicationController
  before_action :set_district, only: [:show, :edit, :update, :destroy]

  # GET /districts
  # GET /districts.json
  def index
    authorize @districts = District.all
  end

  # GET /districts/1
  # GET /districts/1.json
  def show
  end

  # GET /districts/new
  def new
    authorize @district = District.new
  end

  # GET /districts/1/edit
  def edit
  end

  # POST /districts
  # POST /districts.json
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
  # PATCH/PUT /districts/1.json
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
  # DELETE /districts/1.json
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
