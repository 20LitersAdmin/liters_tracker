# frozen_string_literal: true

class TechnologiesController < ApplicationController
  before_action :set_technology, only: %i[show edit update destroy]

  def all
    authorize @technologies = Technology.all

    @reports = Report.order(date: :asc)

    @earliest = form_date @reports.first.date
    @latest = form_date @reports.last.date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to = params[:to].present? ? Date.parse(params[:to]) : @latest
  end

  # GET /technologies
  def index
    authorize @technologies = Technology.all
  end

  # GET /technologies/1
  def show
  end

  # GET /technologies/new
  def new
    authorize @technology = Technology.new
  end

  # GET /technologies/1/edit
  def edit
  end

  # POST /technologies
  def create
    authorize @technology = Technology.new(technology_params)

    respond_to do |format|
      if @technology.save
        format.html { redirect_to @technology, notice: 'Technology was successfully created.' }
        format.json { render :show, status: :created, location: @technology }
      else
        format.html { render :new }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /technologies/1
  # PATCH/PUT /technologies/1.json
  def update
    respond_to do |format|
      if @technology.update(technology_params)
        format.html { redirect_to @technology, notice: 'Technology was successfully updated.' }
        format.json { render :show, status: :ok, location: @technology }
      else
        format.html { render :edit }
        format.json { render json: @technology.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /technologies/1
  # DELETE /technologies/1.json
  def destroy
    @technology.destroy
    respond_to do |format|
      format.html { redirect_to technologies_url, notice: 'Technology was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_technology
    authorize @technology = Technology.find(params[:id])
  end

  def technology_params
    params.require(:technology).permit(:name, :default_impact, :agreement_required, :scale, :direct_cost, :indirect_cost, :us_cost, :local_cost)
  end
end
