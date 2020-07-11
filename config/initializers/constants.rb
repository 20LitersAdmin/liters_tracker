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
    HIERARCHY = %w[Country District Sector Cell Village Facility].freeze
    CONTROLLERS = %w[countries districts sectors cells villages facilities].freeze
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

  class Params
    # when storing previous URLs, ignore the URL if the action is one of these
    # see ApplicationController#bad_param?()
    BAD_ACTIONS = %w[create
                     children
                     destroy dttb_index
                     edit
                     handler
                     image destroy_image upload_image
                     new
                     redirector
                     stats
                     users update].freeze
  end

  class Population
    HOUSEHOLD_SIZE = 5
  end

  class Story
    # https://developer.mozilla.org/en-US/docs/Web/HTML/Element/img
    IMAGE_FORMATS = %w[apng bmp ico svg tiff webp png jpeg jpg gif].freeze
  end
end
