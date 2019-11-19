# frozen_string_literal: true

class Story < ApplicationRecord
  require 'mini_magick'
  require 'fileutils'

  belongs_to :report, inverse_of: :story

  validates_presence_of :title, :text, :report_id

  scope :between_dates, ->(start_date, end_date) { joins(:report).where('reports.date BETWEEN ? AND ?', start_date, end_date) }
  scope :ordered_by_date, -> { joins(:report).order('reports.date DESC') }
  scope :with_images, -> { where.not(image_name: nil) }

  # if the image is localized, it's probably because it's new, or a transform was called on it (resize or rotate).
  # upload_image! needs to happen before_save so that #image_name and #image_version get written to the database.
  before_save :upload_image!, if: -> { image_localized? }
  after_save :delete_local_file, unless: -> { image_name.blank? }

  def date
    report.date
  end

  def download_image
    return false unless image_uploaded?

    # this would potentially allow an image that breaks naming convention to be downloaded
    # but should prevent duplicates in s3
    s3_image.get(response_target: image_path)

    # this would potentially create duplicates in s3 if localize_image transforms the name
    # and then re-uploads it under a new name
    # image_io = s3_image.get() # image written to memory
    # localize_image(image_io)

    image_localized?
  end

  # TODO: delete this after deleting the database column
  def image
    raise ">>>  Don't use `.image`, use `.picture`  <<< (if you really need the database value of `.image`, use `.read_attribute(:image)`)"
  end

  def image_localized?
    return false unless image_name.present?

    File.exist?(image_path)
  end

  def image_path
    return false unless image_name.present?

    Rails.root.join(Constants::Story::IMAGE_DIR, image_name)
  end

  def image_right_sized?
    return false unless image_localized?

    image = MiniMagick::Image.open(image_path)
    image.width == 355
  end

  def image_uploaded?
    return false unless image_name.present?

    s3_image.exists?
  end

  def localize_image!(image_io)
    return false unless image_io.present?

    image_extension = image_io.original_filename.split(/\./).last

    # set the image_name on the record
    self.image_name = "#{report_id}_#{report.date.year}-#{report.date.month}.#{image_extension}"

    return false unless Constants::Story::IMAGE_FORMATS.include?(image_extension.downcase)

    # save image locally
    File.open(image_path, 'wb') do |file|
      file.write(image_io.read)
    end

    # auto-resizing by default
    resize_image

    File.exist?(image_path)
  end

  def picture
    return 'story_no_image.png' if image_name.blank?

    url = "#{Constants::Story::IMAGE_URL}#{image_name}"

    url += "?ver=#{image_version}" if image_version.present?

    url
  end

  def resize_image
    return false unless find_or_download_image

    # resize the image to 355 wide, setting height by aspect ratio
    image = MiniMagick::Image.new(image_path)
    image.resize '355'
  end

  def related(limit = nil)
    ilimit = limit.to_i

    id_ary = []
    # related by technology
    id_ary << Story.joins(:report).where.not(id: id).where('reports.technology_id = ?', report.technology_id).pluck(:id)
    # related by sector
    # only if report.reportable is a sector or below
    id_ary << report.reportable.sector.related_stories.where.not(id: id).pluck(:id) if Constants::Geography::DISTRICT_CHILDREN.include?(report.reportable_type)
    # related by date
    id_ary << Story.joins(:report).where.not(id: id).where('reports.date = ?', report.date).pluck(:id)

    if (id_ary.flatten.uniq.size + ilimit).zero?
      # Return an empty set if limit is nil && no related stories are found
      Story.none
    elsif id_ary.flatten.uniq.size >= ilimit
      # We have enough related stories!
      # if limit is nil, return all related stories
      Story.where(id: id_ary.flatten.uniq).limit(limit)
    else
      # we need to inject some random stories
      # if limit is nil, this clause is not reached.
      remainder = ilimit - id_ary.flatten.uniq.size

      rem_ids_ary = Story.where.not(id: id_ary.flatten.uniq).limit(remainder).order('RANDOM()').pluck(:id)
      id_ary << rem_ids_ary
      Story.where(id: id_ary.flatten.uniq)
    end
  end

  def rotate_image(direction)
    return false unless find_or_download_image

    rotation = direction == 'left' ? '-90' : '90'

    image = MiniMagick::Image.new(image_path)
    image.rotate rotation
  end

  def s3_image
    return false unless image_name.present?

    aws_access = Rails.env.production? ? ENV['AWS_ACCESS_KEY'] : Rails.application.credentials.aws[:access_key]
    aws_secret = Rails.env.production? ? ENV['AWS_SECRET_KEY'] : Rails.application.credentials.aws[:secret_key]

    s3 = Aws::S3::Resource.new(
      region: 'us-east-2',
      credentials: Aws::Credentials.new(aws_access, aws_secret)
    )

    s3.bucket(Constants::Story::S3_BUCKET).object('images/' + image_name)
  end

  def upload_image!
    return false unless image_name.present? && image_localized? # && Rails.env.production?

    resize_image unless image_right_sized?

    s3_image.upload_file(image_path)
    self.img_version = s3_image.version_id
  end

  # TODO: run on all Stories after next push
  def migrate_image_name
    return if image_name == read_attribute(:image).gsub(Constants::Story::IMAGE_URL, '')

    self.image_name = read_attribute(:image).gsub(Constants::Story::IMAGE_URL, '')
    begin
      self.image_version = s3_image.version_id
    rescue Aws::S3::Errors::NotFound
      puts 'no version info found'
    end

    save
  end

  private

  def find_or_download_image
    return false unless image_name.present?

    download_image if image_uploaded? && !image_localized?

    File.exist?(image_path)
  end

  def delete_local_file
    File.delete(image_path) if File.exist?(image_path)
  end
end
