# frozen_string_literal: true

class CreateTechnologies < ActiveRecord::Migration[5.2]
  def change
    create_table :technologies do |t|
      t.string :name,                null: false
      t.string :short_name,          null: false
      t.integer :default_impact,     null: false
      t.boolean :agreement_required, null: false, default: false
      t.string :scale,               null: false
      t.monetize :direct_cost
      t.monetize :indirect_cost
      t.monetize :us_cost
      t.monetize :local_cost

      t.timestamps
    end
  end
end
