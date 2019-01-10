# frozen_string_literal: true

class CreateFacilities < ActiveRecord::Migration[5.2]
  def change
    create_table :facilities do |t|
      t.string :name,        null: false
      t.string :description
      t.float :latitude
      t.float :longitude
      t.integer :population
      t.integer :households
      t.string :category,    null: false
      t.references :village, null: false

      t.timestamps
    end
  end
end
