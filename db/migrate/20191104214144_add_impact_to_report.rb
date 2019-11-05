# frozen_string_literal: true

class AddImpactToReport < ActiveRecord::Migration[6.0]
  def change
    add_column :reports, :impact, :integer, default: 0
  end
end
