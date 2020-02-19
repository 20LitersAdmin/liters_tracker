# frozen_string_literal: true

class ExpandReports < ActiveRecord::Migration[6.0]
  def change
    add_column :technologies, :is_engagement, :boolean, default: false
    add_column :technologies, :dashboard_worthy, :boolean, default: true

    add_column :reports, :hours, :decimal, default: 0, precision: 5, scale: 2

    add_index :technologies, :is_engagement
    add_index :technologies, :dashboard_worthy
  end
end
