# frozen_string_literal: true

class UpdatesController < ApplicationController
  before_action :set_update, only: %i[show edit update destroy]

  # GET /updates
  # GET /updates.json
  def index
    authorize @updates = Update.all
  end

  # GET /updates/1
  # GET /updates/1.json
  def show
  end

  # GET /updates/new
  def new
    authorize @update = Update.new
  end

  # GET /updates/1/edit
  def edit
  end

  # POST /updates
  # POST /updates.json
  def create
    authorize @update = Update.new(update_params)

    respond_to do |format|
      if @update.save
        format.html { redirect_to @update, notice: 'Update was successfully created.' }
        format.json { render :show, status: :created, location: @update }
      else
        format.html { render :new }
        format.json { render json: @update.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /updates/1
  # PATCH/PUT /updates/1.json
  def update
    respond_to do |format|
      if @update.update(update_params)
        format.html { redirect_to @update, notice: 'Update was successfully edited.' }
        format.json { render :show, status: :ok, location: @update }
      else
        format.html { render :edit }
        format.json { render json: @update.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /updates/1
  # DELETE /updates/1.json
  def destroy
    @update.destroy
    respond_to do |format|
      format.html { redirect_to updates_url, notice: 'Update was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def process
    # handle the creation of multiple updates from sectors/#id/report

    # params[:updates].each do |single_update_params|
    #   Don't forget to set the globalID
    #   Update.create(single_update_params)
    # end
  end

  private

  def set_update
    authorize @update = Update.find(params[:id])
  end

  def update_params
    params.require(:update).permit(:date, :technology_id, :distributed, :checked, :user_id, :model_gid, :distribute, :check)
  end
end
