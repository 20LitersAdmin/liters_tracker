# frozen_string_literal: true

module CleanupCrew
  def clean_up!
    model_list = Dir['app/models/*.rb'].map { |f| File.basename(f, '.*').camelize.constantize } - [ApplicationRecord, Monthly]

    model_list.each(&:destroy_all)

    ActiveRecord::Base.connection.tables.each do |t|
      ActiveRecord::Base.connection.reset_pk_sequence!(t)
    end
  end
end
