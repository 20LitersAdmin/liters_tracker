# frozen_string_literal: true

class StoriesController < ApplicationController
  before_action :set_story, only: %i[show edit update destroy image upload_image rotate_image destroy_image]
  before_action :set_report_from_param, only: %i[new create]
  before_action :set_report, only: %i[show edit update destroy]
  layout 'dashboard', only: %i[show]

  def index
    @stories = Story.ordered_by_date
  end

  def show
    @title = @story.title
    @subtitle = "Reported by #{@story.report.user.name}"
    @related_stories = @story.related(3)

    @breadcrumb = @story.breadcrumb
    @technology = @story.technology
  end

  def new
    # TODO: what am I doing with year && month params?
    @story ||= Story.new
    @story.report_id = @report.id
    @year = params[:year]
    @month = params[:month]

    authorize @story
  end

  def create
    # TODO: what am I doing with year && month params?
    authorize @story = Story.new(story_params)

    if @story.save
      flash[:success] = 'Story was successfully created.'

      if params[:month].blank? || params[:year].blank?
        redirect_to image_story_path(@story)
      else
        redirect_to image_story_path(@story, month: params[:month], year: params[:year])
      end
    else
      @year = params[:year]
      @month = params[:month]
      render :new
    end
  end

  def edit
    # TODO: what am I doing with year && month params?
    @year = params[:year]
    @month = params[:month]
  end

  def update
    # TODO: what am I doing with year && month params?
    if @story.update(story_params)
      flash[:success] = 'Story was successfully edited.'

      if params[:month].blank? || params[:year].blank?
        redirect_to image_story_path(@story)
      else
        redirect_to image_story_path(@story, month: params[:month], year: params[:year])
      end
    else
      @year = params[:year]
      @month = params[:month]
      render :edit
    end
  end

  def image
    @report = @story.report
    @year = params[:year]
    @month = params[:month]

    if @story.image.attached?
      render :image_edit
    else
      render :image_new
    end
  end

  def upload_image
    unless params.include? :story
      flash[:error] = 'Oops, no image selected.'
      redirect_to image_story_path(@story, month: params[:month], year: params[:year])
      return
    end

    if @story.process_image!(image_params[:image])
      flash[:success] = 'Image was successfully saved.'

      # TODO: what am I doing with year && month params?
      redirect_to image_story_path(@story, month: params[:month], year: params[:year])

      # if params[:month].blank? || params[:year].blank?
      #   redirect_to @story
      # else
      #   redirect_to monthly_w_date_url(month: params[:month], year: params[:year])
      # end
    else
      @year = params[:year]
      @month = params[:month]
      render :image
    end
  end

  def rotate_image
    if @story.rotate_image!(params[:direction])
      flash[:success] = "Image rotated #{params[:direction]}."
    else
      flash[:error] = 'Something went wrong.'
    end
    # TODO: If I need year && month, I'm loosing them here?
    redirect_to image_story_path(@story)
  end

  def destroy_image
    @story.image.purge
    flash[:success] = 'Image successfully deleted.'
    # TODO: If I need year && month, I'm loosing them here?
    redirect_to image_story_path(@story)
  end

  private

  def story_params
    params.require(:story).permit(:title, :prominent, :text, :report_id)
  end

  def image_params
    params.require(:story).permit(:image)
  end

  def set_story
    @story = Story.find(params[:id])
    authorize @story
  end

  def set_report_from_param
    report_id = params[:report_id].nil? ? story_params[:report_id] : params[:report_id]
    if report_id.blank?
      year = params[:year]
      month = params[:month]
      # TODO: should this be @return_path?
      redirect_back(fallback_location: monthly_w_date_path(year: year, month: month))
      flash[:error] = 'Something went wrong and the report_id wasn\'t properly associated to this new story. Please navigate back and try again!'
    else
      @report = Report.find(report_id)
    end
  end

  def set_report
    @report = @story.report
  end
end
