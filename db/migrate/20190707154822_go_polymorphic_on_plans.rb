# frozen_string_literal: true

class GoPolymorphicOnPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :planable_id, :integer
    add_column :plans, :planable_type, :string

    add_index :plans, [:planable_type, :planable_id]
  end
end
