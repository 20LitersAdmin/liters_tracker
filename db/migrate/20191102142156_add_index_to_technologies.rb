# frozen_string_literal: true

class AddIndexToTechnologies < ActiveRecord::Migration[6.0]
  def change
    add_index :technologies, :report_worthy
  end
end
