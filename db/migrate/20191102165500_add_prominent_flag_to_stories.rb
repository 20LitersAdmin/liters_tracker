# frozen_string_literal: true

class AddProminentFlagToStories < ActiveRecord::Migration[5.2]
  def change
    add_column :stories, :prominent, :boolean, default: false
  end
end
