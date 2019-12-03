# frozen_string_literal: true

class AddStuffToTechnology < ActiveRecord::Migration[6.0]
  def change
    add_column :technologies, :image_name, :string
    add_column :technologies, :description, :text
  end
end
