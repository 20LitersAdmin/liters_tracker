# frozen_string_literal: true

class StoriesController < ApplicationController
  before_action :set_story, only: %i[show edit update destroy image upload_image rotate_image destroy_image]
  before_action :set_report_from_param, only: %i[new create]
  before_action :set_report, only: %i[show edit update destroy image]
  before_action :set_monthly, only: %i[new show edit image]
  layout 'dashboard', only: %i[show]

  def index
    @stories = Story.ordered_by_date
  end

  def show
    @title = @story.title
    @reporter = @report.user.name
    @subtitle = "Reported by #{@reporter}"
    @related_stories = @story.related(3)

    @hierarchy = @story.report.hierarchy
    @technology = @story.technology

    @author = @story.user.name

    @tagline = @reporter == @author ? "Reported by #{@author}" : "Reported by #{@reporter}, Story written by #{@author}"
  end

  def new
    @story ||= Story.new
    @story.report_id = @report.id
    authorize @story
  end

  def create
    authorize @story = Story.new(story_params)

    @story.user = current_user

    if @story.save
      flash[:success] = 'Story was successfully created.'

      redirect_to image_story_path(@story)
    else
      @year = params[:year]
      @month = params[:month]
      render :new
    end
  end

  def edit; end

  def update
    @story.user = current_user

    if @story.update(story_params)
      flash[:success] = 'Story was successfully edited.'

      redirect_to image_story_path(@story)
    else
      @year = params[:year]
      @month = params[:month]
      render :edit
    end
  end

  def image
    @reporter = @report.user.name
    @author = @story.user.name

    if @story.image.attached?
      render :image_edit
    else
      render :image_new
    end
  end

  def upload_image
    unless params.include? :story
      flash[:error] = 'Oops, no image selected.'
      redirect_to image_story_path(@story)
      return
    end

    if @story.process_image!(image_params[:image])
      flash[:success] = 'Image was successfully saved.'
      redirect_to image_story_path(@story)
    else
      render :image
    end
  end

  def rotate_image
    if @story.rotate_image!(params[:direction])
      flash[:success] = "Image rotated #{params[:direction]}."
    else
      flash[:error] = 'Something went wrong.'
    end
    redirect_to image_story_path(@story)
  end

  def destroy_image
    @story.image.purge
    flash[:success] = 'Image successfully deleted.'
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
      redirect_to @return_path
      flash[:error] = 'Something went wrong and the report_id wasn\'t properly associated to this new story. Please navigate back and try again!'
    else
      @report = Report.find(report_id)
    end
  end

  def set_report
    @report = @story.report
  end

  def set_monthly
    @monthly = Monthly.new(year: @report.year, month: @report.month)
    @monthly_report_name = "#{Date::MONTHNAMES[@monthly.month][0..2]}, #{@monthly.year}"
  end
end
