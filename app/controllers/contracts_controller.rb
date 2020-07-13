# frozen_string_literal: true

class ContractsController < ApplicationController
  before_action :set_contract, only: [:show, :edit, :update, :destroy]

  # GET /contracts
  # GET /contracts.json
  def index
    authorize @contracts = Contract.order(start_date: :desc)
  end

  # GET /contracts/1
  # GET /contracts/1.json
  def show
    @targets = @contract.targets.joins(:technology).order('technologies.name ASC')

    @untargeted_technologies_exist = (Technology.all.pluck(:id) - @contract.targets.pluck(:technology_id)).any?

    @plans = @contract.plans.includes(:technology).order(date: :asc)
  end

  # GET /contracts/new
  def new
    authorize @contract = Contract.new
  end

  # GET /contracts/1/edit
  def edit
    @start_date = form_date(@contract.start_date) || nil
  end

  # POST /contracts
  # POST /contracts.json
  def create
    authorize @contract = Contract.new(contract_params)

    respond_to do |format|
      if @contract.save
        format.html { redirect_to @contract, success: 'Contract created.' }
        format.json { render :show, status: :created, location: @contract }
      else
        format.html { render :new }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contracts/1
  # PATCH/PUT /contracts/1.json
  def update
    respond_to do |format|
      if @contract.update(contract_params)
        format.html { redirect_to @contract, success: 'Contract updated.' }
        format.json { render :show, status: :ok, location: @contract }
      else
        format.html { render :edit }
        format.json { render json: @contract.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contracts/1
  # DELETE /contracts/1.json
  def destroy
    @contract.destroy
    respond_to do |format|
      format.html { redirect_to contracts_url, notice: 'Contract deleted.' }
      format.json { head :no_content }
    end
  end

  private

  def set_contract
    authorize @contract = Contract.find(params[:id])
  end

  def contract_params
    params.require(:contract).permit(:start_date,
                                     :end_date,
                                     :budget,
                                     :household_goal,
                                     :people_goal,
                                     plans_attributes: [
                                       :contract_id,
                                       :technology_id,
                                       :goal,
                                       :people_goal,
                                       :planable_type,
                                       :planable_id
                                      ])
  end
end
