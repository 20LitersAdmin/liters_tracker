class StoriesController < ApplicationController

	def index
	end
	
	def show
	end

	def new
	end

	def create
      save_image(params)
    end
	
	private

	def save_image(params)
	  image_io = params[:stories][:picture]

	  File.open(Rails.root.join('tmp', image_io.original_filename), 'wb') do |file|
        file.write(image_io.read)
      end
      
      s3 = Aws::S3::Resource.new(
      	region:'us-east-2',
        credentials: Aws::Credentials.new(Rails.application.credentials.aws[:access_key], Rails.application.credentials.aws[:secret_key])
      ) # todo what region
      obj = s3.bucket('20litres-images').object(image_io.original_filename)
      obj.upload_file(Rails.root.join('tmp', image_io.original_filename))

	end

end
