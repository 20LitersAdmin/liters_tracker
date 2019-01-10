# frozen_string_literal: true

class CreateDistricts < ActiveRecord::Migration[5.2]
  def change
    create_table :districts do |t|
      t.string :name, null: false
      t.integer :gis_id
      t.float :latitude
      t.float :longitude
      t.integer :population
      t.integer :households

      t.timestamps
      t.index :gis_id, unique: true
    end
  end
end
