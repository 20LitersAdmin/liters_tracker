# frozen_string_literal: true

class VillagesController < ApplicationController
  before_action :set_village, only: %w[show edit update destroy children make_visible]

  # GET /villages
  def index
    authorize @villages = Village.visible.order(:name)

    @show_hidden = Village.hidden.any?

    @earliest = form_date Report.earliest_date
    @latest =   form_date Report.latest_date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to =   params[:to].present? ? Date.parse(params[:to]) : @latest
  end

  def hidden
    authorize @villages = Village.hidden.includes(:cell, :sector, :district).select(:id, :name, :cell_id).order(:name)
    @show_visible = Village.visible.any?
  end

  # GET /villages/1
  def show
    if @village.hidden?
      flash[:error] = "This village is currently hidden. Please #{view_context.link_to('edit', edit_village_path(@village)).html_safe} the record to make it visible."
      flash[:html_safe] = true
    end

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

    @reports = @village.related_reports.between(@from, @to)
    @plans = @village.related_plans.between(@from, @to)
    @technologies = Technology.report_worthy
    @plan_date = human_date @plans.size.zero? ? nil : Contract.find(@plans.pluck(:contract_id).max).end_date
    @facilities = @village.facilities.order(name: :asc)
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
        format.html { redirect_to @village, notice: 'Village created.' }
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
        format.html { redirect_to @village, notice: 'Village updated.' }
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
      format.html { redirect_to villages_url, notice: 'Village destroyed.' }
      format.json { head :no_content }
    end
  end

  ## sectors#reports ajax
  ## plans#_form ajax
  def children
    render json: @village.facilities.select(:id, :name).order(:name)
  end

  def make_visible
    @village.update(hidden: false)

    redirect_to villages_path
  end

  private

  def set_village
    authorize @village = Village.find(params[:id])
  end

  def village_params
    params.require(:village).permit(:name,
                                    :gis_code,
                                    :latitude,
                                    :longitude,
                                    :population,
                                    :households,
                                    :hidden)
  end
end
