class StoriesController < ApplicationController
  before_action :set_story, only: %i[show edit update destroy]
  layout "dashboard", :only => [ :show ]

	def index
    @stories = Story.all.order(:title)
	end

	def show
	end

  def new
    @story = Story.new
    @story.report_id = params[:report_id]
    @year = params[:year]
    @month = params[:month]

    authorize @story
  end

  def edit
    @year = params[:year]
    @month = params[:month]
  end

  # PATCH /stories
  # PATCH /stories.json
  def update
    updated_params = story_params.except(:photo)
    if story_params[:photo]
      new_urls = @story.save_image(story_params[:photo])
      updated_params[:image] = new_urls[:raw]
      updated_params[:image_thumbnail] = new_urls[:thumbnail]
    else
      updated_params[:image] = @story.image
      updated_params[:image_thumbnail] = @story.image_thumbnail
    end

    respond_to do |format|
      if @story.update(updated_params)
        if params[:month].blank? || params[:year].blank?
          format.html { redirect_to stories_path, notice: 'Report was successfully edited.' }
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
    # does this work wth our image saving stuff
    #handle image
    authorize @story = Story.new(story_params.except(:photo))
    if (!story_params[:photo].blank?)
      urls = @story.save_image(story_params[:photo])
      @story.image = urls[:raw]
      @story.image_thumbnail = urls[:thumbnail]
    else
      @story.image = ""
      @story.image_thumbnail = ""
    end

    respond_to do |format|
      if @story.save
        if params[:month].blank? || params[:year].blank?
          format.html { redirect_to @story, notice: 'Report was successfully created.' }
        else
          format.html { redirect_to monthly_w_date_url(:month => params[:month], :year => params[:year]), notice: 'Report was successfully created.' }
        end

        format.json { render :show, status: :created, location: @story }
      else
        # todo can we keep the form elements on error?
        @year = params[:year]
        @month = params[:month]
        format.html { render :new }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end

	private

  def story_params
    params.require(:story).permit(:title, :prominent, :text, :photo, :report_id)
  end

  def set_story
    @story = Story.find(params[:id])
    authorize @story
  end

end
