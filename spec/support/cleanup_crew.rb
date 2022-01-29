# frozen_string_literal: true

module CleanupCrew
  def clean_up!
    # This cannot be allowed to run in production
    # I believe it's safe because the require call only exists in RSpec's rails_helper
    abort('The Rails environment isn\'t Test!!!') unless Rails.env.test?

    # Shhh. Clean while the tests are running.
    # puts 'CleanupCrew has arrived.'

    Facility.destroy_all
    Village.destroy_all
    Cell.destroy_all
    Sector.destroy_all
    District.destroy_all
    Country.destroy_all

    Story.destroy_all
    Report.destroy_all
    Plan.destroy_all
    Target.destroy_all
    Contract.destroy_all

    Technology.destroy_all

    User.destroy_all

    # puts 'Mess is gone, boss.'

    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end

    # puts 'Lights are off, doors are locked. Good night.'
  end

  module_function :clean_up!
end
