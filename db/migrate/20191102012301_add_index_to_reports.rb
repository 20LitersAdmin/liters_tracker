# frozen_string_literal: true

class AddIndexToReports < ActiveRecord::Migration[6.0]
  def change
    add_index :reports, :date
  end
end
