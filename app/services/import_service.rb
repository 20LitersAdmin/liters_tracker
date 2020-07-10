# frozen_string_literal: true

class ImportService
  def self.import_geographies
    path = Rails.root.join 'public'

    districts_path = path.join 'rw_districts.csv'
    sectors_path = path.join 'rw_sectors.csv'
    cells_path = path.join 'rw_cells.csv'
    villages_path = path.join 'rw_villages.csv'

    District.import(districts_path)

    puts 'Done with districts'

    Sector.import(sectors_path)

    puts 'Done with sectors'

    Cell.import(cells_path)

    puts 'Done with cells'

    Village.import(villages_path)

    puts 'Done with villages'
  end
end
