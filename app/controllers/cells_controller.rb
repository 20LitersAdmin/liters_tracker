# frozen_string_literal: true

class CellsController < ApplicationController
  before_action :set_cell, only: [:show, :edit, :update, :destroy]

  # GET /cells
  # GET /cells.json
  def index
    authorize @cells = Cell.all.order(:name)
  end

  # GET /cells/1
  # GET /cells/1.json
  def show
  end

  # GET /cells/new
  def new
    authorize @cell = Cell.new
  end

  # GET /cells/1/edit
  def edit
  end

  # POST /cells
  # POST /cells.json
  def create
    authorize @cell = Cell.new(cell_params)

    respond_to do |format|
      if @cell.save
        format.html { redirect_to @cell, notice: 'Cell was successfully created.' }
        format.json { render :show, status: :created, location: @cell }
      else
        format.html { render :new }
        format.json { render json: @cell.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cells/1
  # PATCH/PUT /cells/1.json
  def update
    respond_to do |format|
      if @cell.update(cell_params)
        format.html { redirect_to @cell, notice: 'Cell was successfully updated.' }
        format.json { render :show, status: :ok, location: @cell }
      else
        format.html { render :edit }
        format.json { render json: @cell.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cells/1
  # DELETE /cells/1.json
  def destroy
    @cell.destroy
    respond_to do |format|
      format.html { redirect_to cells_url, notice: 'Cell was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_cell
    authorize @cell = Cell.find(params[:id])
  end

  def cell_params
    params.require(:cell).permit(:name, :gis_id, :latitude, :longitude, :population, :households)
  end
end
