# frozen_string_literal: true

class Story < ApplicationRecord
  belongs_to :report
  scope :get_stories_by_year, ->(year_string) { joins(:report).where('reports.date BETWEEN ? AND ?', "#{year_string}-01-01", "#{year_string}-12-31")}

  def save_image(image_io)

    if Rails.env.production? == false
      return {
      	raw: '',
      	thumbnail: ''
      }
    end

    # do not upload the file to s3 if the extension is not an image
    # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/img
    image_extension = image_io.original_filename.split(/\./).last
    unless ['apng','bmp', 'ico', 'svg', 'tiff', 'webp', 'png', 'jpeg', 'jpg', 'gif'].include? image_extension.downcase
      return {
        raw: '',
        thumbnail: ''
      }
    end

    # rename image to something consistent and safe
    image_name = "#{report_id}.#{image_extension}"
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
    # todo - should image be separated from cdn url?
    {
      raw: "https://d5t73r6km0hzm.cloudfront.net/images/#{image_name}",
      thumbnail: "https://d5t73r6km0hzm.cloudfront.net/thumbnails/#{image_name}"
    }
  end

  def related
    []
  end

end
