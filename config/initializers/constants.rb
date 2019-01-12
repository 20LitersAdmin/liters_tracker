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

    MODEL_LIST = %w[Cell Contract Data District Facility Permission Plan Report Sector Target Technology User Village].freeze
  end

  class Geography
    STACK_HSH = { 'District' => 0, 'Sector' => 1, 'Cell' => 2, 'Village' => 3, 'Facility' => 4 }.freeze
    STACK_ARY = %w[District Sector Cell Village Facility].freeze
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
end
