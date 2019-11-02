class StoriesController < ApplicationController

	def index
	end

	def show
	end

  def new
    @report_id = params[:report_id]
  end

  def edit
    @story = Story.find(params[:id])
  end

    # POST /stories
    # POST /stories.json
	def create
	  # save_image(params)
      # does this work wth our image saving stuff
      authorize @story = Story.new(story_params)
      
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
	  image_io = params[:stories][:photo]
      image_path = Rails.root.join('tmp', image_io.original_filename)

      aws_id = Rails.application.credentials.aws[:access_key]
      aws_key = Rails.application.credentials.aws[:secret_key]

	  File.open(image_path, 'wb') do |file|
        file.write(image_io.read)
      end
      
      s3 = Aws::S3::Resource.new(
      	region:'us-east-2',
        credentials: Aws::Credentials.new(aws_id, aws_key)
      )

      obj = s3.bucket('20litres-images').object(image_io.original_filename)
      obj.upload_file(image_path)

      File.delete(image_path) if File.exist?(image_path)
	end

end
