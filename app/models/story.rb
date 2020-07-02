# frozen_string_literal: true

class Story < ApplicationRecord
  require 'mini_magick'
  require 'fileutils'

  belongs_to :report, inverse_of: :story
  belongs_to :user, inverse_of: :stories
  has_one_attached :image, dependent: :purge
  has_one :technology, through: :report

  validates_presence_of :title, :text, :report_id

  validate :check_image_format, if: -> { image.attached? }

  scope :between_dates, ->(start_date, end_date) { joins(:report).where('reports.date BETWEEN ? AND ?', start_date, end_date) }
  scope :ordered_by_date, -> { joins(:report).order('reports.date DESC') }

  def date
    report.date
  end

  # call story.attach(params[:image]) to attach an image to an existing story
  # story.image.attached?
  # story.image.purge
  # story.image.purge_later

  # Generate a permanent URL for the blob that points to the application. Upon access, a redirect to the actual service endpoint is returned.
  # url_for(story.image)

  # To create a download link, use the `rails_blob_{path|url}` helper. Using this helper allows you to set the disposition.
  # rails_blob_path(story.image, disposition: 'attachment')

  # If you need to create a link from outside of controller/view context (Background jobs, Cronjobs, etc.), you can access the rails_blob_path like this:
  # Rails.application.routes.url_helpers.rails_blob_path(story.image, only_path: true)

  # Sometimes you need to process a blob after it's uploaded:
  # binary = story.image.download

  def picture
    image.attached? ? Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true) : ActionController::Base.helpers.asset_path('story_no_image.png')
  end

  def process_image!(image_io)
    unless image_io.content_type.start_with? 'image/'
      errors.add(:image, 'needs to be an image')
      return false
    end

    # allowing .attach() to replace the image uses .perge_later which is not what I want
    # so we first purge the image
    image.purge if image.attached?

    mini_image = magick_image(image_io.tempfile.path)
    # always resize the image to 355px wide, height automagically selected to preserve aspect ratio.
    # this overwrites image_io
    mini_image.resize '355'

    # rename
    image_name = "#{report_id}_#{report.date.year}-#{report.date.month}.#{image_io.original_filename.split(/\./)[1]}"

    image.attach(io: File.open(image_io.tempfile.path), filename: image_name, content_type: image_io.content_type)

    image.attached?
  end

  # returns a set number of related stories. This is used on Storise#show view.
  # stories are related to each other by technology, sector and date
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

  def rotate_image!(direction)
    return false unless %w[left right].include?(direction) && image.attached?

    rotation = direction == 'left' ? -90 : 90

    # create a local copy
    filename = image.filename.to_s
    content_type = image.blob.content_type

    attachment_path = "#{Dir.tmpdir}/#{filename}"

    File.open(attachment_path, 'wb') do |file|
      file.write(image.download)
      file.close
    end

    mini_image = magick_image(attachment_path)
    # this overwrites image_io
    mini_image.rotate rotation

    # allowing .attach() to replace the image uses .perge_lager which is not what I want
    image.purge
    image.attach(io: File.open(attachment_path), filename: filename, content_type: content_type)

    image.attached?
  end

  private

  def check_image_format
    return true if image.content_type.start_with? 'image/'

    image.persisted? ? image.purge : image.delete

    errors.add(:image, 'needs to be an image')
  end

  def magick_image(path)
    MiniMagick::Image.new(path)
  end
end

# Never trigger an analyzer when calling methods on ActiveStorage
ActiveStorage::Blob::Analyzable.module_eval do
  def analyze_later; end

  def analyzed?
    true
  end
end
