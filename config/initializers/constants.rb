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

  class Technology
    SCALE = %w[Family Community].freeze
  end

  class Facility
    CATEGORY = %w[Church Clinic School Other].freeze
  end
end
