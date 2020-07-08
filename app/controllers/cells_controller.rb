# frozen_string_literal: true

class CellsController < ApplicationController
  before_action :set_cell, only: %w[show edit update destroy children]

  # GET /cells
  # GET /cells.json
  def index
    authorize @cells = Cell.all.order(:name)
  end

  # GET /cells/1
  # GET /cells/1.json
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

    @reports = @cell.related_reports.between(@from, @to)
    @plans = @cell.related_plans.between(@from, @to)
    @technologies = Technology.report_worthy
    @plan_date = human_date @plans.size.zero? ? nil : Contract.find(@plans.pluck(:contract_id).max).end_date
    @villages = @cell.villages.order(name: :asc)
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

  ## facilities#form and facilities#modal_form ajax
  ## sectors#reports ajax
  ## plans#_form ajax
  def children
    render json: @cell.villages.select(:id, :name).order(:name)
  end

  private

  def set_cell
    authorize @cell = Cell.find(params[:id])
  end

  def cell_params
    params.require(:cell).permit(:name, :gis_code, :latitude, :longitude, :population, :households)
  end
end
