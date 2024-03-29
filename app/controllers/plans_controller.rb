# frozen_string_literal: true

class PlansController < ApplicationController
  before_action :set_plan, only: %i[edit update destroy]
  before_action :set_contract, only: %i[edit create dttb_index]

  def dttb_index
    authorize @plans = @contract.plans.includes(:technology).order(date: :asc)

    respond_to do |format|
      format.html
      format.json { render 'index', layout: false }
    end
  end

  # GET /plans/1
  # GET /plans/1.json
  def show; end

  # GET /plans/1/edit
  def edit
    @contracts = Contract.all.order(:name).pluck(:name, :id)
    @technologies = Technology.report_worthy.order(:name).pluck(:name, :id)
    @min_date = @contract.start_date
    @max_date = @contract.end_date
  end

  # POST /plans
  # POST /plans.json
  def create
    authorize @plan = Plan.where(dup_matching_params).first_or_initialize

    @plan.assign_attributes(plan_params)
    @plan.contract_id = @contract.id

    @persistence = @plan.new_record? ? 'Plan created.' : 'A matching plan was found and updated.'

    respond_to do |format|
      if @plan.save
        format.html { redirect_to @return_path, notice: @persistence }
        format.json { render :show, status: :created, location: @plan }
        format.js do
          @technology = @plan.technology
          @partial = "contracts/#{@technology.type}_plans"
          @sector = @plan.planable.sector
          @plans = @sector.related_plans.where(technology: @technology).nearest_to_date(@plan.date)

          render :plan_created, layout: false
        end
      else
        format.html { render :new }
        format.json { render json: @plan.errors, status: :unprocessable_entity }
        format.js { render :plan_error, layout: false }
      end
    end
  end

  # PATCH/PUT /plans/1
  # PATCH/PUT /plans/1.json
  def update
    respond_to do |format|
      if @plan.update(plan_params)
        format.html { redirect_to @return_path, notice: 'Plan updated.' }
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
      format.html { redirect_to @return_path, notice: 'Plan deleted.' }
      format.json { head :no_content }
      format.js { render :plan_destroyed, layout: false }
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
    params.require(:plan).permit(:technology_id,
                                 :goal,
                                 :people_goal,
                                 :planable_type,
                                 :planable_id,
                                 :date)
  end

  def dup_matching_params
    params.require(:plan).permit(:date,
                                 :technology_id,
                                 :planable_id,
                                 :planable_type)
  end
end
