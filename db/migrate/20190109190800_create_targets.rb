# frozen_string_literal: true

class CreateTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :targets do |t|
      t.references :contract, foreign_key: true
      t.references :technology, foreign_key: true
      t.integer :goal, null: false
      t.integer :people_goal

      t.timestamps
    end
  end
end
