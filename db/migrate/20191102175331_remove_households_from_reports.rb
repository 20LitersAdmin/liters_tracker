class RemoveHouseholdsFromReports < ActiveRecord::Migration[6.0]
  def change
    remove_column :reports, :households
  end
end
