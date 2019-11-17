# frozen_string_literal: true

class AddYearAndMonthToReports < ActiveRecord::Migration[6.0]
  def change
    add_column :reports, :year, :integer
    add_column :reports, :month, :integer
  end
end
