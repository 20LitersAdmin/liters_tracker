class StoriesController < ApplicationController
  before_action :set_story, only: %i[show edit update destroy]

	def index
	end

	def show
	end

  def new
    @story = Story.new
    @story.report_id = params[:report_id]
  end

  def edit
  end

  # PATCH /stories
  # PATCH /stories.json
  def update
    updated_params = story_params.except(:photo)
    if story_params[:photo]
      new_urls = save_image(story_params)
      updated_params[:image] = new_urls[:raw]
      updated_params[:image_thumbnail] = new_urls[:thumbnail]
    else
      updated_params[:image] = @story.image
      updated_params[:image_thumbnail] = @story.image_thumbnail
    end

    respond_to do |format|
      if @story.update(updated_params)
        format.html { redirect_to @story, notice: 'Report was successfully edited.' }
        format.json { render :show, status: :ok, location: @story }
      else
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
    urls = save_image(story_params)
    @story.image = urls[:raw]
    @story.image_thumbnail = urls[:thumbnail]
      
    respond_to do |format|
      if @story.save
        format.html { redirect_to @story, notice: 'Report was successfully created.' }
        format.json { render :show, status: :created, location: @story }
      else
        # todo can we keep the form elements on error?
        format.html { render :new }
        format.json { render json: @story.errors, status: :unprocessable_entity }
      end
    end
  end
	
	private

	def save_image(params)

	  image_io = params[:photo]

    # rename image to something consistent and safe
    image_extension = image_io.original_filename.split(/\./).last
    image_name = "#{params[:report_id]}.#{image_extension}"
    image_path = Rails.root.join('tmp', image_name)
    

    # get aws creds
    aws_id = Rails.application.credentials.aws[:access_key]
    aws_key = Rails.application.credentials.aws[:secret_key]

    # save image temporarily to send to s3
	  File.open(image_path, 'wb') do |file|
      file.write(image_io.read)
    end
      
    s3 = Aws::S3::Resource.new(
      region:'us-east-2',
      credentials: Aws::Credentials.new(aws_id, aws_key)
    )

    img = s3.bucket('20litres-images').object("images/#{image_name}")
    img.upload_file(image_path)

    # todo handle thumbnails, correct res
    thumb = s3.bucket('20litres-images').object("thumbnails/#{image_name}")
    thumb.upload_file(image_path)

    # cleanup temporary image to keep filespace safe
    # File.delete(image_path) if File.exist?(image_path)
    { 
      raw: "https://d5t73r6km0hzm.cloudfront.net/images/#{image_name}",
      thumbnail: "https://d5t73r6km0hzm.cloudfront.net/thumbnails/#{image_name}"
    }
	end

  def story_params
    params.require(:story).permit(:title, :text, :photo, :report_id)
  end

  def set_story
    @story = Story.find(params[:id])
    authorize @story
  end

end
