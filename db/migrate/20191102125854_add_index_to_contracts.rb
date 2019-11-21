# frozen_string_literal: true

class AddIndexToContracts < ActiveRecord::Migration[6.0]
  def change
    add_index :contracts, :end_date
    add_index :contracts, [:end_date, :start_date], name: 'between_end_start_dates'
  end
end
