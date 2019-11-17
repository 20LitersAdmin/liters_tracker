# frozen_string_literal: true

class Story < ApplicationRecord
  belongs_to :report, inverse_of: :story

  validates_presence_of :title, :text

  scope :between_dates, ->(start_date, end_date) { joins(:report).where('reports.date BETWEEN ? AND ?', start_date, end_date) }

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

  def upload_image(image_io)
    image_extension = image_io.original_filename.split(/\./).last
    # do not upload unless in production
    # do not upload the file to s3 if the extension is not an image, also restricted in the form field
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
    aws_id = ENV['AWS_ACCESS_KEY']
    aws_key = ENV['AWS_SECRET_KEY']

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

    {
      raw: "https://d5t73r6km0hzm.cloudfront.net/images/#{image_name}?ver=#{img_ver}",
      thumbnail: "https://d5t73r6km0hzm.cloudfront.net/thumbnails/#{image_name}?ver=#{thumb_ver}"
    }
  end

  def picture
    image.blank? ? 'story_no_image.png' : image
  end
end
