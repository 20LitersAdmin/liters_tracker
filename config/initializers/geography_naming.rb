# frozen_string_literal: true

module GeographyNaming
  extend ActiveSupport::Concern

  def type
    # return nil unless Constants::Geography::ALLOWED.include? self.class.name

    if country.name == 'United States'
      Constants::Geography::US_NAMES[self.class.name]
    else
      self.class.name
    end
  end
end
