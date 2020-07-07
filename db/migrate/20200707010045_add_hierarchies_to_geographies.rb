# frozen_string_literal: true

class AddHierarchiesToGeographies < ActiveRecord::Migration[6.0]
  include Rails.application.routes.url_helpers

  def up
    add_column :districts, :hierarchy, :jsonb
    add_column :sectors, :hierarchy, :jsonb
    add_column :cells, :hierarchy, :jsonb
    add_column :villages, :hierarchy, :jsonb
    add_column :facilities, :hierarchy, :jsonb

    District.all.each do |d|
      d.update_column(:hierarchy, [{ parent_name: d.country.name, parent_type: 'Country', link: country_path(d.country) }])
    end

    Sector.all.each do |s|
      s.update_column(:hierarchy, s.district.hierarchy << { parent_name: s.district.name, parent_type: 'District', link: district_path(s.district) })
    end

    Cell.all.each do |c|
      c.update_column(:hierarchy, c.sector.hierarchy << { parent_name: c.sector.name, parent_type: 'Sector', link: sector_path(c.sector) })
    end

    Village.all.each do |v|
      v.update_column(:hierarchy, v.cell.hierarchy << { parent_name: v.cell.name, parent_type: 'Cell', link: cell_path(v.cell) })
    end

    Facility.all.each do |f|
      f.update_column(:hierarchy, f.village.hierarchy << { parent_name: f.village.name, parent_type: 'Village', link: village_path(f.village) })
    end
  end

  def down
    remove_column :districts, :hierarchy
    remove_column :sectors, :hierarchy
    remove_column :cells, :hierarchy
    remove_column :villages, :hierarchy
    remove_column :facilities, :hierarchy
  end
end
