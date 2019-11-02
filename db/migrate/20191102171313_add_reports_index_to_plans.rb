class AddReportsIndexToPlans < ActiveRecord::Migration[6.0]
  def change
    add_index :plans, [:contract_id, :technology_id, :planable_id, :planable_type], unique: true, name: 'idx_has_many_reports'
  end
end
