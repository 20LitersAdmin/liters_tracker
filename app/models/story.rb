# frozen_string_literal: true

class Story < ApplicationRecord
  belongs_to :report, inverse_of: :story
  scope :between_dates, ->(start_date, end_date) { joins(:report).where('reports.date BETWEEN ? AND ?', start_date, end_date)}
  
  validates_presence_of :title, :text

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
    aws_id = ''
    aws_key = ''
    if Rails.env.production?
      aws_id = ENV['AWS_ACCESS_KEY']
      aws_key = ENV['AWS_SECRET_KEY']
    else
      aws_id = Rails.application.credentials.aws[:access_key]
      aws_key = Rails.application.credentials.aws[:secret_key]
    end

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
    # grab a random offset to start grabing stories at
    offset = rand(Story.all.size-4)
    # rand of a negative is zero, but we should be explicit
    offset = 0 if offset.negative?
    # grab 4 stories (this story could be one of them)
    random_stories = Story.offset(offset).first(4)
    # limit down to the stories that are not us
    random_stories.select {|story| story.id != id}
    # todo - add a query to get related stories
    # similar technology id
    # similar geography (reportable)
    related = []
    # grab the first 3 stories, prioritizing the related stories
    (related + random_stories).first(3)
  end

  def self.array_of_unique_dates
    joins(:report).order('reports.date ASC').pluck('reports.date').uniq
  end

  # helper function that can be used in the future to bin and sort all stories in the data base
  #
  #
  # OUTPUT:
  #
  #
  # all_stories = 
  #  {
  #
  #     "2019": {"Jac" .. "Dec"} .. "XXX": {"Jac" .. "Dec"}
  #  }
  #
  #
  def self.bin_all_stories
    binned_stories = {} # variable for the final return of stories that are binned by month
    months = Date.const_get(:ABBR_MONTHNAMES).compact # returns nil as the first entry, so use compact to remove it
    years = self.get_story_years
    years.each do |y|
      tmp_hash = {}
      (1..12).step(1) do |m|
        # start with the first month and build a hash of all stories that are binned by a month
        tmp_date = Date.new(y, m)
        tmp_stories = self.between_dates(tmp_date.beginning_of_month, tmp_date.end_of_month)
        tmp_hash[Date.const_get(:ABBR_MONTHNAMES)[m]] = tmp_stories #convert digit to abbreviated month name
      end
      binned_stories[y.to_s] = tmp_hash # store off the hashes of stories associated by month and year
    end
    binned_stories
  end


  def self.bin_stories_by_year(year)
    month_list = []
    story_collection = nil
    (1..12).step(1) do |m|
      tmp_date = Date.new(year, m)
      # start with the first month and build a hash of all stories that are binned by a month
      tmp_stories = self.between_dates(tmp_date.beginning_of_month, tmp_date.end_of_month)
      if tmp_stories.size > 0 # check if there are stories for this month
        month_list << Date.const_get(:ABBR_MONTHNAMES)[m]
        if story_collection.nil?
          story_collection = tmp_stories
        else
          story_collection += tmp_stories
        end
      end
    end
    return month_list, story_collection
  end

  def self.get_story_years
    self.array_of_unique_dates.map(&:year).uniq.sort.reverse
  end

  def picture
    image.blank? ? 'story_no_image.png' : image
  end
end
