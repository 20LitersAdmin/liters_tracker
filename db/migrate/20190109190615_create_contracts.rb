# frozen_string_literal: true

class CreateContracts < ActiveRecord::Migration[5.2]
  def change
    create_table :contracts do |t|
      t.date :start_date, null: false
      t.date :end_date,   null: false
      t.money :budget
      t.integer :household_goal
      t.integer :people_goal

      t.timestamps
    end
  end
end
