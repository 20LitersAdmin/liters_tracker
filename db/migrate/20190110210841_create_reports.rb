# frozen_string_literal: true

class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.date :date
      t.references :technology, foreign_key: true, null: false
      t.references :user,       foreign_key: true, null: false
      t.references :contract,   foreign_key: true, null: false
      t.string :model_gid,                         null: false
      t.integer :distributed
      t.integer :checked

      t.timestamps
    end
  end
end
