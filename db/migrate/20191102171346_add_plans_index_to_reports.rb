# frozen_string_literal: true

class AddPlansIndexToReports < ActiveRecord::Migration[6.0]
  def change
    add_index :reports, [:contract_id, :technology_id, :reportable_id, :reportable_type], name: 'idx_belongs_to_plan'
  end
end
