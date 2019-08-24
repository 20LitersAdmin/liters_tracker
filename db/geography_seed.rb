# frozen_string_literal: true

Country.create([
  { name: 'Rwanda', gis_code: 1 },
  { name: 'United States', gis_code: 2 }
])

District.all.where(country_id: nil).update_all(country_id: 1)

District.create(name: 'Midwest', gis_code: 100, country_id: Country.last.id)

Sector.create(name: 'Michigan', gis_code: 1001, district_id: District.last.id)

Cell.create([
  { name: 'Kent', gis_code: 10011, sector_id: Sector.last.id },
  { name: 'Ottawa', gis_code: 10012, sector_id: Sector.last.id }
])
