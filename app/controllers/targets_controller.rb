# frozen_string_literal: true

class TargetsController < ApplicationController
  before_action :set_target, only: %i[edit update destroy]
  before_action :set_contract, only: %i[new create update]

  # GET /targets/1/edit
  def new
    @target = Target.new

    # force users to edit existing Target records by
    # only allowing them to create new Targets with 'unused' technologies
    targeted_technologies = @contract.targets.pluck(:technology_id)
    @untargeted_technologies = Technology.where.not(id: targeted_technologies).order(name: :asc).pluck(:name, :id)
  end

  # GET /targets/1/edit
  def edit
    @contract = @target.contract
  end

  # POST /targets
  # POST /targets.json
  def create
    authorize @target = Target.new(target_params)

    @target.contract = @contract

    respond_to do |format|
      if @target.save
        format.html { redirect_to @return_path, notice: 'Target created.' }
        format.json { render :show, status: :created, location: @target }
      else
        @contract = Contract.find(params[:contract_id])
        targeted_technologies = @contract.targets.pluck(:technology_id)
        @untargeted_technologies = Technology.where.not(id: targeted_technologies).order(name: :asc).pluck(:name, :id)
        format.html { render :new }
        format.json { render json: @target.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /targets/1
  # PATCH/PUT /targets/1.json
  def update
    respond_to do |format|
      if @target.update(target_params)
        format.html { redirect_to @return_path, notice: 'Target updated.' }
        format.json { render :show, status: :ok, location: @target }
      else
        format.html { render :edit }
        format.json { render json: @target.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /targets/1
  # DELETE /targets/1.json
  def destroy
    @target.destroy
    respond_to do |format|
      format.html { redirect_to @return_path, notice: 'Target deleted.' }
      format.json { head :no_content }
    end
  end

  private

  def set_target
    authorize @target = Target.find(params[:id])
  end

  def set_contract
    @contract = Contract.find(params[:contract_id])
  end

  def target_params
    params.require(:target).permit(:technology_id, :goal, :people_goal)
  end
end
