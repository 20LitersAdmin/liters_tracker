# frozen_string_literal: true

class CreateSectors < ActiveRecord::Migration[5.2]
  def change
    create_table :sectors do |t|
      t.string :name,         null: false
      t.references :district, null: false
      t.integer :gis_id
      t.float :latitude
      t.float :longitude
      t.integer :population
      t.integer :households

      t.timestamps
    end
  end
end
