# frozen_string_literal: true

class StoriesController < ApplicationController
  before_action :set_story, only: %i[show edit update destroy rotate_img destroy_img]
  before_action :set_report_from_url, only: %i[new]
  before_action :set_report, only: %i[show edit update create destroy]
  layout 'dashboard', only: %i[show]

  def index
    @stories = Story.ordered_by_date
  end

  def show
    @related_stories = @story.related(3)
  end

  def new
    @story ||= Story.new
    @story.report_id = @report.id
    @year = params[:year]
    @month = params[:month]

    authorize @story
  end

  def edit
    @year = params[:year]
    @month = params[:month]

    flash[:error] = 'Something went wrong and the report_id wasn\'t properly associated to this new story. Please navigate back and try again!' if @story.report_id.blank?
  end

  # PATCH /stories
  # PATCH /stories.json
  def update
    updated_params = story_params.except(:photo)
    @story.localize_image(story_params[:photo]) if story_params[:photo].present?

    respond_to do |format|
      if @story.update(updated_params)
        if params[:month].blank? || params[:year].blank?
          format.html { redirect_to stories_path, notice: 'Story was successfully edited.' }
        else
          format.html { redirect_to monthly_w_date_url(:month => params[:month], :year => params[:year]), notice: 'Report was successfully edited.' }
        end

        format.json { render :show, status: :ok, location: @story }
      else
        @year = params[:year]
        @month = params[:month]
        format.html { render :edit }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /stories
  # POST /stories.json
  def create
    # handle image
    authorize @story = Story.new(story_params.except(:photo))
    @story.localize_image(story_params[:photo]) unless @story.image_localized? || story_params[:photo].blank?

    respond_to do |format|
      if @story.save
        if params[:month].blank? || params[:year].blank?
          format.html { redirect_to @story, notice: 'Story was successfully created.' }
        else
          format.html { redirect_to monthly_w_date_url(month: params[:month], year: params[:year]), notice: 'Report was successfully created.' }
        end

        format.json { render :show, status: :created, location: @story }
      else
        # TODO: can we keep the form elements on error?

        @year = params[:year]
        @month = params[:month]
        format.html { render :new }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

  def rotate_img
    unless params[:direction].present?
      redirect_to edit_story_path(@story)
      flash[:error] = 'No direction set'
    end
  end

  def destroy_img
  end

  def eager_img
    # js call to take the image_io
    # call @story.localize_image()
    # get a temp location
  end

  private

  def story_params
    params.require(:story).permit(:title, :prominent, :text, :photo, :report_id)
  end

  def set_story
    @story = Story.find(params[:id])
    authorize @story
  end

  def set_report_from_param
    if params[:report_id].blank
      redirect_back
      flash[:error] = 'Something went wrong and the report_id wasn\'t properly associated to this new story. Please navigate back and try again!'
    else
      @report = Report.find(params[:report_id])
    end
  end

  def set_report
    @report = @story.report
  end
end
