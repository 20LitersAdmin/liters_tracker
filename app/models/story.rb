# frozen_string_literal: true

class Story < ApplicationRecord
  belongs_to :report, inverse_of: :story
  scope :between_dates, ->(start_date, end_date) { joins(:report).where('reports.date BETWEEN ? AND ?', start_date, end_date) }

  validates_presence_of :title, :text

  def related(limit = nil)
    ilimit = limit.to_i

    id_ary = []
    # related by technology
    id_ary << Story.joins(:report).where.not(id: id).where('reports.technology_id = ?', report.technology_id).pluck(:id)
    # related by sector
    id_ary << report.reportable.sector.related_stories.where.not(id: id).pluck(:id)
    # related by date
    id_ary << Story.joins(:report).where.not(id: id).where('reports.date = ?', report.date).pluck(:id)

    if id_ary.flatten.uniq.size >= ilimit
      # we have enough related stories!
      Story.where(id: id_ary.flatten.uniq).limit(limit)
    else
      # we need to inject some random stories

      remainder = ilimit - id_ary.flatten.uniq.size
      rem_ids_ary = Story.where.not(id: id_ary.flatten.uniq).limit(remainder).order('RANDOM()').pluck(:id)
      id_ary << rem_ids_ary
      Story.where(id: id_ary.flatten.uniq)
    end
  end

  def save_image(image_io)
    image_extension = image_io.original_filename.split(/\./).last
    # do not upload unless in production
    # do not upload the file to s3 if the extension is not an image,also restricted in the form field
    unless Rails.env.production? && Constants::Story::IMAGE_FORMATS.include?(image_extension.downcase)
      return {
        raw: '',
        thumbnail: ''
      }
    end

    # rename image to something consistent and safe
    image_name = "#{report_id}_#{report.date.year}-#{report.date.month}.#{image_extension}"
    image_path = Rails.root.join('tmp', image_name)

    # save image temporarily to send to s3
    File.open(image_path, 'wb') do |file|
      file.write(image_io.read)
    end

    # get aws creds
    if Rails.env.production?
      aws_id = ENV['AWS_ACCESS_KEY']
      aws_key = ENV['AWS_SECRET_KEY']
    else
      aws_id = Rails.application.credentials.aws[:access_key]
      aws_key = Rails.application.credentials.aws[:secret_key]
    end

    s3 = Aws::S3::Resource.new(
      region: 'us-east-2',
      credentials: Aws::Credentials.new(aws_id, aws_key)
    )

    img = s3.bucket('20litres-images').object("images/#{image_name}")
    img.upload_file(image_path)
    img_ver = img.version_id

    # TODO: handle thumbnails, correct res
    thumb = s3.bucket('20litres-images').object("thumbnails/#{image_name}")
    thumb.upload_file(image_path)
    thumb_ver = img.version_id

    # cleanup temporary image to keep filespace safe
    File.delete(image_path) if File.exist?(image_path)

    # TODO: should image be separated from cdn url?
    {
      raw: "https://d5t73r6km0hzm.cloudfront.net/images/#{image_name}?ver=#{img_ver}",
      thumbnail: "https://d5t73r6km0hzm.cloudfront.net/thumbnails/#{image_name}?ver=#{thumb_ver}"
    }
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
