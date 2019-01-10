# frozen_string_literal: true

class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.references :contract, foreign_key: true
      t.references :technology, foreign_key: true
      t.string :model_gid, null: false
      t.integer :goal,     null: false
      t.integer :people_goal

      t.timestamps
    end
  end
end
