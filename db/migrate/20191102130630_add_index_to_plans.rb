class AddIndexToPlans < ActiveRecord::Migration[6.0]
  def change
    add_index :plans, :created_at
  end
end
