class StoriesController < ApplicationController

	def index
	end
	def show
	end
	def new
	end

	def create
	  puts params.inspect
	  image_io = params[:stories][:picture]

	  File.open(Rails.root.join('tmp', image_io.original_filename), 'wb') do |file|
        file.write(image_io.read)
      end
      puts Rails.application.credentials.aws[:secret_access_key]
      puts Rails.application.credentials.aws[:access_key_id]
      s3 = Aws::S3::Resource.new(region:'us-east-2') #todo what region
      obj = s3.bucket('20litres-images').object(image_io.original_filename)
      puts obj.inspect
      obj.upload_file(Rails.root.join('tmp', image_io.original_filename))
      puts obj.inspect

	  # uploaded_io = params[:person][:picture]
      # File.open(Rails.root.join('public', 'uploads', uploaded_io.original_filename), 'wb') do |file|
      #   file.write(uploaded_io.read)
      # end
    end
	

end
