# frozen_string_literal: true

class CreateCountries < ActiveRecord::Migration[6.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.integer :gis_code
      t.float :latitude
      t.float :longitude
      t.integer :population
      t.integer :households

      t.timestamps
    end

    change_table :districts do |t|
      t.references :country
    end

    add_index :countries, :gis_code
  end
end
