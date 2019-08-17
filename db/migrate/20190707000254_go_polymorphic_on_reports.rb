class GoPolymorphicOnReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :reportable_id, :integer
    add_column :reports, :reportable_type, :string

    add_index :reports, [:reportable_type, :reportable_id]
  end
end
