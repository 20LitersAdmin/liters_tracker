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
    ALLOWED = %w[Country District Sector Cell Village Facility].freeze
    US_NAMES = { 'Country' => 'Country', 'District' => 'Region', 'Sector' => 'State', 'Cell' => 'County', 'Village' => 'City', 'Facility' => 'Facility' }.freeze
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
end
