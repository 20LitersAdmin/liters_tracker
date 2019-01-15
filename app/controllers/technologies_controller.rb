# frozen_string_literal: true

class TechnologiesController < ApplicationController
  before_action :set_technology, only: %i[show edit update destroy]

  # GET /technologies
  def index
    authorize @technologies = Technology.report_worthy
    @tech_ids = @technologies.pluck(:id)

    @earliest = form_date Report.earliest_date
    @latest =   form_date Report.latest_date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to =   params[:to].present? ? Date.parse(params[:to]) : @latest

    @targets = Target.where(technology_id: @tech_ids).between(@from, @to).order(contract_id: :asc)
    @reports = Report.where(technology_id: @tech_ids).where(date: @from..@to).order(date: :asc)
    @target_date = @targets.last&.date
  end

  # GET /technologies/1
  def show
    @earliest = form_date Report.earliest_date
    @latest =   form_date Report.latest_date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to =   params[:to].present? ? Date.parse(params[:to]) : @latest

    @reports = Report.where(technology: @technology).where(date: @from..@to)

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
      @target_date = @targets.last&.date
    else
      @sectors = Sector.all
      @plans = Plan.where(technology: @technology).between(@from, @to)
      @plan_date = human_date @plans.last&.date
    end
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
