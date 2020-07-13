# frozen_string_literal: true

class DistrictsController < ApplicationController
  before_action :set_district, only: %i[show edit update destroy children make_visible]

  # GET /districts
  def index
    authorize @districts = District.visible.order(:name)

    @show_hidden = District.hidden.any?

    @earliest = form_date Report.earliest_date
    @latest =   form_date Report.latest_date

    @from = params[:from].present? ? Date.parse(params[:from]) : @earliest
    @to =   params[:to].present? ? Date.parse(params[:to]) : @latest

    @reports = Report.between(@from, @to).order(date: :asc)
    @plans = Plan.between(@from, @to)

    contract_id = @plans.select(:contract_id).maximum(:contract_id)
    @plan_date = human_date @plans.size.zero? ? nil : Contract.find(contract_id).end_date
  end

  def hidden
    authorize @districts = District.hidden.includes(:country).select(:id, :name, :country_id).order(:name)
    @show_visible = District.visible.any?
  end

  # GET /districts/:id
  def show
    flash[:error] = "This district is currently hidden. Please #{view_context.link_to('edit', edit_country_path(@country)).html_safe} the record to make it visible."
    flash[:html_safe] = true

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

    @reports = @district.related_reports.between(@from, @to)
    @plans = @district.related_plans.between(@from, @to)
    @technologies = Technology.report_worthy
    @plan_date = human_date @plans.size.zero? ? nil : Contract.find(@plans.pluck(:contract_id).max).end_date
    @sectors = @district.sectors.order(name: :asc)
  end

  # GET /districts/new
  def new
    authorize @district = District.new
  end

  # GET /districts/1/edit
  def edit; end

  # POST /districts
  def create
    authorize @district = District.new(district_params)

    respond_to do |format|
      if @district.save
        format.html { redirect_to @district, notice: 'District was successfully created.' }
        format.json { render :show, status: :created, location: @district }
      else
        format.html { render :new }
        format.json { render json: @district.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /districts/1
  def update
    respond_to do |format|
      if @district.update(district_params)
        format.html { redirect_to @district, notice: 'District was successfully updated.' }
        format.json { render :show, status: :ok, location: @district }
      else
        format.html { render :edit }
        format.json { render json: @district.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /districts/1
  def destroy
    @district.destroy
    respond_to do |format|
      format.html { redirect_to districts_url, notice: 'District was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  ## facilities#_form ajax
  ## plans#_form ajax
  ## sectors#report ajax
  def children
    render json: @district.sectors.select(:id, :name).order(:name)
  end

  def make_visible
    @district.update(hidden: false)

    redirect_to districts_path
  end

  private

  def set_district
    authorize @district = District.find(params[:id])
  end

  def district_params
    params.require(:district).permit(:name,
                                     :gis_code,
                                     :latitude,
                                     :longitude,
                                     :population,
                                     :households,
                                     :hidden)
  end
end
