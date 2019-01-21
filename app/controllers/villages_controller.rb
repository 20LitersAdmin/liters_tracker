# frozen_string_literal: true

class VillagesController < ApplicationController
  before_action :set_village, only: %w[show edit update destroy]

  # GET /villages
  def index
    authorize @villages = Village.all.order(:name)

    @earliest = form_date Report.earliest_date
    @latest =   form_date Report.latest_date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to =   params[:to].present? ? Date.parse(params[:to]) : @latest

    @reports = Report.where(date: @from..@to).order(date: :asc)
    @plans = Plan.between(@from, @to)

    @plan_date = human_date @plans.size.zero? ? nil : Contract.find(@plans.pluck(:contract_id).max).end_date

    @pop_hh_ary = @villages.pluck(:population, :households)
    @gttl_pop = @pop_hh_ary.map { |vil| vil[0] }.compact.sum
    @gttl_hh = @pop_hh_ary.map { |vil| vil[1] }.compact.sum
    @gttl_pop_hh = view_context.number_with_delimiter(@gttl_pop, delimiter: ',') + ' / ' + view_context.number_with_delimiter(@gttl_hh, delimiter: ',')

    @a_reps_dist_chk = @reports.pluck(:distributed, :checked)
    @gttl_dist = @a_reps_dist_chk.map { |rep| rep[0] }.compact.sum
    @gttl_chk = @a_reps_dist_chk.map { |rep| rep[1] }.compact.sum
    @gttl_dist_chk = view_context.number_with_delimiter(@gttl_dist, delimiter: ',') + ' / ' + view_context.number_with_delimiter(@gttl_chk, delimiter: ',')

    @skip_blanks = params[:skip_blanks].present?
    @skip_blanks_rfp = request.fullpath.include?('?') ? request.fullpath + '&skip_blanks=true' : request.fullpath + '?skip_blanks=true'

    @searchbar_hidden_fields = [{ name: 'skip_blanks', value: 'true' }] if @skip_blanks
    @contract_search_param_add = @skip_blanks ? '&skip_blanks=true' : ''
  end

  # GET /villages/1
  def show
  end

  # GET /villages/new
  def new
    authorize @village = Village.new
  end

  # GET /villages/1/edit
  def edit
  end

  # POST /villages
  def create
    authorize @village = Village.new(village_params)

    respond_to do |format|
      if @village.save
        format.html { redirect_to @village, notice: 'Village was successfully created.' }
        format.json { render :show, status: :created, location: @village }
      else
        format.html { render :new }
        format.json { render json: @village.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /villages/1
  def update
    respond_to do |format|
      if @village.update(village_params)
        format.html { redirect_to @village, notice: 'Village was successfully updated.' }
        format.json { render :show, status: :ok, location: @village }
      else
        format.html { render :edit }
        format.json { render json: @village.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /villages/1
  def destroy
    @village.destroy
    respond_to do |format|
      format.html { redirect_to villages_url, notice: 'Village was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_village
    authorize @village = Village.find(params[:id])
  end

  def village_params
    params.require(:village).permit(:name, :gis_id, :latitude, :longitude, :population, :households)
  end
end
