# frozen_string_literal: true

class CreateStories < ActiveRecord::Migration[5.2]
  def change
    create_table :stories do |t|
      t.string :title
      t.string :text
      t.string :image
      t.string :image_thumbnail
      t.references :report, foreign_key: true, null: false, index: true
      t.timestamps
    end
  end
end
