# frozen_string_literal: true

module GeographyType
  extend ActiveSupport::Concern

  def type
    if country.name == 'United States'
      Constants::Geography::US_NAMES[self.class.name]
    else
      self.class.name
    end
  end
end
