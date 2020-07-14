# frozen_string_literal: true

class GisVerificationService
  def self.analyze(api: false)
    ActiveRecord::Base.logger.silence do
      puts 'Starting analysis' unless api
      issues = []

      puts 'Analyzing villages' unless api
      Village.all.each do |v|
        district_from_v = v.gis_code.to_s[0..1]
        sector_from_v = v.gis_code.to_s[0..3]
        cell_from_v = v.gis_code.to_s[0..5]

        issues << { village: [v.name, v.id], district: [v.district.name, v.district.id], village_gis: v.gis_code.to_s, district_gis: v.district.gis_code.to_s } if v.district.gis_code.to_s != district_from_v
        issues << { village: [v.name, v.id], sector: [v.sector.name, v.sector.id], village_gis: v.gis_code.to_s, sector_gis: v.sector.gis_code.to_s } if v.sector.gis_code.to_s != sector_from_v
        issues << { village: [v.name, v.id], cell: [v.cell.name, v.cell.id], village_gis: v.gis_code.to_s, cell_gis: v.cell.gis_code.to_s } if v.cell.gis_code.to_s != cell_from_v
      end
      puts 'Done analyzing villages' unless api

      puts 'Analyzing cells' unless api
      Cell.all.each do |c|
        district_from_c = c.gis_code.to_s[0..1]
        sector_from_c = c.gis_code.to_s[0..3]

        issues << { cell: [c.name, c.id], district: [c.district.name, c.district.id], cell_gis: c.gis_code.to_s, district_gis: c.district.gis_code.to_s } if c.district.gis_code.to_s != district_from_c
        issues << { cell: [c.name, c.id], sector: [c.sector.name, c.sector.id], cell_gis: c.gis_code.to_s, sector_gis: c.sector.gis_code.to_s } if c.sector.gis_code.to_s != sector_from_c
      end
      puts 'Done analyzing cells' unless api

      puts 'Analyzing sectors' unless api
      Sector.all.each do |s|
        district_from_s = s.gis_code.to_s[0..1]

        issues << { sector: [s.name, s.id], district: [s.district.name, s.district.id], sector_gis: s.gis_code.to_s, district_gis: s.district.gis_code.to_s } if s.district.gis_code.to_s != district_from_s
      end
      puts 'Done analyzing villages' unless api

      if api
        issues
      elsif issues.any?
        puts "Found #{issues.size} issues:"
        puts issues
      else
        puts 'No issues found'
      end
    end
  end

  def self.correct
    ActiveRecord::Base.logger.silence do
      geography_parser = {
        district: 1,
        sector: 3,
        cell: 5
      }

      puts 'Running analysis in api mode'
      results = analyze(api: true)

      changes = []

      puts "Found #{results.size} issues:"

      return unless results.any?

      puts 'Fixing issues...'

      results.each do |r|
        child_class = Kernel.const_get(r.keys[0].to_s.capitalize)
        parent_class = Kernel.const_get(r.keys[1].to_s.capitalize)

        child = child_class.find(r.values[0][1])

        gis_fragment_length = geography_parser[r.keys[1]]

        child_gis_fragment = child.gis_code.to_s[0..gis_fragment_length].to_i

        real_parent = parent_class.where(gis_code: child_gis_fragment).first

        next if real_parent.nil?

        if child.update(r.keys[1] => real_parent)
          changes << { r.keys[0] => r.values[0], (r.keys[1].to_s + '_old').to_sym => r.values[1], (r.keys[1].to_s + '_new').to_sym => [real_parent.name, real_parent.id] }
        end
      end
      puts "Fixed #{changes.size} of #{results.size} issues:"

      puts changes
    end
  end
end
