# frozen_string_literal: true

class CreateTechnologies < ActiveRecord::Migration[5.2]
  def change
    create_table :technologies do |t|
      t.string :name,                null: false
      t.string :short_name,          null: false
      t.integer :default_impact,     null: false
      t.boolean :agreement_required, null: false, default: false
      t.string :scale,               null: false
      t.money :direct_cost
      t.money :indirect_cost
      t.money :us_cost
      t.money :local_cost

      t.timestamps
    end
  end
end
