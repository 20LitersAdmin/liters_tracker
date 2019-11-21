# frozen_string_literal: true

class AddIndexToPlans < ActiveRecord::Migration[6.0]
  def change
    add_column :plans, :date, :date
    add_index :plans, :date
  end
end
