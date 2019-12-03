# frozen_string_literal: true

class RemoveImageStuffFromStories < ActiveRecord::Migration[6.0]
  def change
    remove_column :stories, :image_name, :string
    remove_column :stories, :image_version, :string
  end
end
