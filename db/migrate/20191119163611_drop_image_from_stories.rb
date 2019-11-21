# frozen_string_literal: true

class DropImageFromStories < ActiveRecord::Migration[6.0]
  def change
    remove_column :stories, :image
  end
end
