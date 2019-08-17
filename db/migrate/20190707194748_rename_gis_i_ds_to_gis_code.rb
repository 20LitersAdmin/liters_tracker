class RenameGisIDsToGisCode < ActiveRecord::Migration[5.2]
  def change
    rename_column :cells, :gis_id, :gis_code
    rename_column :districts, :gis_id, :gis_code
    rename_column :sectors, :gis_id, :gis_code
    rename_column :villages, :gis_id, :gis_code
  end
end
