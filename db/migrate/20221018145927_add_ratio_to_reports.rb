# frozen_string_literal: true

class AddRatioToReports < ActiveRecord::Migration[7.0]
  def up
    add_column :reports, :ratio, :integer, default: 0, null: false

    puts '==> Setting ratios on all existing reports, this will take a while.'
    # before_save: calculate_impact_and_ratio
    Report.all.each(&:save!)
  end

  def down
    remove_column :reports, :ratio
  end
end
