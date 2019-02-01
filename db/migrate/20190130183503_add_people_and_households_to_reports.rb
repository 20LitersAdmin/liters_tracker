# frozen_string_literal: true

class AddPeopleAndHouseholdsToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :people, :integer
    add_column :reports, :households, :integer
  end
end
