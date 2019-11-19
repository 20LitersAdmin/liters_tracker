# frozen_string_literal: true

module Constants
  class Application
    BOOTSTRAP_CLASSES = {
      success: 'success',
      danger: 'danger',
      error: 'danger',
      warning: 'warning',
      alert: 'warning',
      notice: 'secondary'
    }.freeze
  end

  class Geography
    US_NAMES = { 'Country' => 'Country', 'District' => 'Region', 'Sector' => 'State', 'Cell' => 'County', 'Village' => 'City', 'Facility' => 'Facility' }.freeze
    DISTRICT_CHILDREN = %w[Sector Cell Village Facility].freeze
  end

  class Technology
    SCALE = %w[Family Community].freeze
  end

  class Facility
    CATEGORY = %w[Church Clinic School Other].freeze
  end

  class Contract
    CURRENT = 4
  end

  class Population
    HOUSEHOLD_SIZE = 5
  end

  class Story
    # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/img
    IMAGE_FORMATS = %w[apng bmp ico svg tiff webp png jpeg jpg gif].freeze
    IMAGE_DIR = './tmp/s3-storage'
    IMAGE_URL = 'https://d5t73r6km0hzm.cloudfront.net/images/'
    S3_BUCKET = '20litres-images'
    # TODO: Change buckets when ready to use real images:
    # and change Story#s3_image: `.bucket('images/' + image_name)` to `.bucket(image_name)`
    # S3_BUCKET = '20liters-images'
  end
end
