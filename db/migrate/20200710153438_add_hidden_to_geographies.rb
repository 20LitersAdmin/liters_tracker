# frozen_string_literal: true

class AddHiddenToGeographies < ActiveRecord::Migration[6.0]
  def change
    add_column :countries, :hidden, :boolean, default: false, null: false
    add_column :districts, :hidden, :boolean, default: false, null: false
    add_column :sectors, :hidden, :boolean, default: false, null: false
    add_column :cells, :hidden, :boolean, default: false, null: false
    add_column :villages, :hidden, :boolean, default: false, null: false

    add_index :countries, :hidden
    add_index :districts, :hidden
    add_index :sectors, :hidden
    add_index :cells, :hidden
    add_index :villages, :hidden
  end
end
