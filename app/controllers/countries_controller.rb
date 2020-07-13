# frozen_string_literal: true

class CountriesController < ApplicationController
  before_action :set_country, only: %i[show edit update destroy make_visible]

  # GET /countries
  def index
    @countries = Country.visible.order(:name)

    @show_hidden = Country.hidden.any?
  end

  def hidden
    authorize @countries = Country.hidden.order(:name)
    @show_visible = Country.visible.any?
  end

  # GET /countries/1
  def show
    flash[:error] = "This country is currently hidden. Please #{view_context.link_to('edit', edit_country_path(@country)).html_safe} the record to make it visible."
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

    @reports = @country.related_reports.between(@from, @to)
    @plans = @country.related_plans.between(@from, @to)
    @technologies = Technology.report_worthy
    @plan_date = human_date @plans.size.zero? ? nil : Contract.find(@plans.pluck(:contract_id).max).end_date
    @districts = @country.districts.visible.order(name: :asc)
  end

  # GET /countries/new
  def new
    @country = Country.new
  end

  # GET /countries/1/edit
  def edit
  end

  # POST /countries
  def create
    @country = Country.new(country_params)

    if @country.save
      redirect_to @return_path, success: 'Country created.'
    else
      render :new
    end
  end

  # PATCH/PUT /countries/1
  def update
    if @country.update(country_params)
      redirect_to @return_path, success: 'Country updated.'
    else
      render :edit
    end
  end

  # DELETE /countries/1
  def destroy
    @country.destroy
    redirect_to @return_path, success: 'Country destroyed.'
  end

  def make_visible
    @country.update(hidden: false)

    redirect_to countries_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_country
    authorize @country = Country.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def country_params
    params.require(:country).permit(:name,
                                    :gis_code,
                                    :latitude,
                                    :longitude,
                                    :population,
                                    :households,
                                    :hidden)
  end
end
