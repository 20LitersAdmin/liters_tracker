# frozen_string_literal: true

class RenameImageColumns < ActiveRecord::Migration[6.0]
  def change
    add_column :stories, :image_name, :string
    add_column :stories, :image_version, :string
    remove_column :stories, :image_thumbnail
  end
end
