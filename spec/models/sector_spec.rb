# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sector, type: :model do
  let(:sector) { build :sector }

  describe 'has validations on' do
    let(:no_name) { build :sector, name: nil }
    let(:no_district) { build :sector, district: nil }
    let(:bad_district) { build :sector, district_id: 999 }
    let(:no_gis) { build :sector, gis_code: nil }
    let(:duplicate_gis) { build :sector }

    it 'name' do
      no_name.valid?

      expect(no_name.errors[:name]).to match_array("can't be blank")

      no_name.name = 'has a name'
      no_name.valid?

      expect(no_name.errors.any?).to eq false
    end

    it 'district' do
      no_district.valid?
      expect(no_district.errors[:district_id]).to match_array("can't be blank")

      bad_district.valid?
      expect(bad_district.errors[:district]).to match_array('must exist')
    end

    context 'gis_code' do
      it 'can be blank' do
        no_gis.valid?
        expect(no_gis.errors.any?).to eq false
      end

      it 'must be unique' do
        sector.update(gis_code: 1)
        duplicate_gis.gis_code = 1

        duplicate_gis.valid?
        expect(duplicate_gis.errors[:gis_code]).to match_array('has already been taken')
      end
    end
  end

  describe '#cell' do
    it 'returns nil, because I need all Geography models to respond to record.cell' do
      expect(sector.cell).to eq nil
    end
  end

  describe '#child_class' do
    it 'returns "Cell"' do
      expect(sector.child_class).to eq 'Cell'
    end
  end

  describe '#districts' do
    before :all do
      District.destroy_all
    end

    it 'returns siblings of the sector\'s districts' do
      3.times do
        FactoryBot.create(:district, country: sector.district.country)
        FactoryBot.create(:district)
      end

      expect(District.all.size).to eq 7
      expect(sector.districts.size).to eq 4
    end
  end

  describe 'self.import' do
    it 'imports records from a CSV file' do
      FactoryBot.create(:district, gis_code: 11)
      filepath = Rails.root.join 'spec/fixtures/files/rw_sectors.csv'

      expect { Sector.import(filepath) }.to output(/3 records created./).to_stdout
    end
  end

  describe '#parent' do
    it 'returns the parent object' do
      expect(sector.parent).to eq sector.district
    end
  end

  describe '#facility' do
    it 'returns nil, because I need all Geography models to respond to record.facility' do
      expect(sector.facility).to eq nil
    end
  end

  describe '#related_plans' do
    before :each do
      sector.save
    end

    it 'returns plans directly related to the record' do
      plan = FactoryBot.create(:plan_sector, planable: sector)

      expect(sector.reload.related_plans).to include plan
    end

    it 'returns plans related to child cells' do
      cell = FactoryBot.create(:cell, sector: sector)
      plan = FactoryBot.create(:plan_cell, planable: cell)

      expect(sector.reload.related_plans).to include plan
    end

    it 'returns plans related to child villages' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      plan = FactoryBot.create(:plan_village, planable: village)

      expect(sector.reload.related_plans).to include plan
    end

    it 'returns plans related to child facilities' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      facility = FactoryBot.create(:facility, village: village)
      plan = FactoryBot.create(:plan_facility, planable: facility)

      expect(sector.reload.related_plans).to include plan
    end
  end

  describe '#related_reports' do
    before :each do
      sector.save
    end

    it 'returns reports directly related to the record' do
      report = FactoryBot.create(:report_sector, reportable: sector)

      expect(sector.related_reports).to include report
    end

    it 'returns reports related to child cells' do
      cell = FactoryBot.create(:cell, sector: sector)
      report = FactoryBot.create(:report_cell, reportable: cell)

      expect(sector.reload.related_reports).to include report
    end

    it 'returns reports related to child villages' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      report = FactoryBot.create(:report_village, reportable: village)

      expect(sector.reload.related_reports).to include report
    end

    it 'returns reports related to child facilities' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      facility = FactoryBot.create(:facility, village: village)
      report = FactoryBot.create(:report_facility, reportable: facility)

      expect(sector.reload.related_reports).to include report
    end
  end

  describe '#related_stories' do
    before :each do
      sector.save
    end

    it 'returns stories directly related to the record' do
      report = FactoryBot.create(:report_sector, reportable: sector)
      story = FactoryBot.create(:story, report: report)

      expect(sector.reload.related_stories).to include story
    end

    it 'returns stories related to child cells' do
      cell = FactoryBot.create(:cell, sector: sector)
      report = FactoryBot.create(:report_cell, reportable: cell)
      story = FactoryBot.create(:story, report: report)

      expect(sector.reload.related_stories).to include story
    end

    it 'returns stories related to child villages' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      report = FactoryBot.create(:report_village, reportable: village)
      story = FactoryBot.create(:story, report: report)

      expect(sector.reload.related_stories).to include story
    end

    it 'returns stories related to child facilities' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      facility = FactoryBot.create(:facility, village: village)
      report = FactoryBot.create(:report_facility, reportable: facility)
      story = FactoryBot.create(:story, report: report)

      expect(sector.reload.related_stories).to include story
    end
  end

  describe '#sector' do
    it 'returns itself, because I need all Geography models to respond to record.sector' do
      expect(sector.sector).to eq sector
    end
  end

  describe '#sectors' do
    it 'returns siblings of the sector' do
      sector.save
      3.times do
        FactoryBot.create(:sector, district: sector.district)
        FactoryBot.create(:sector)
      end

      expect(Sector.all.size).to eq 7
      expect(sector.sectors.size).to eq 4
    end
  end

  describe '#village' do
    it 'returns nil, because I need all Geography models to respond to record.village' do
      expect(sector.village).to eq nil
    end
  end

  describe '#update_hierarchy' do
    before :all do
      @district = FactoryBot.create(:district)
    end

    it 'is called from after_save' do
      expect(sector).to receive(:update_hierarchy)

      sector.save
    end

    it 'is called if district_id changes' do
      expect(sector).to receive(:update_hierarchy)

      sector.update(district: @district)
    end

    it 'is not called if district_id doesn\'t change' do
      sector.save

      expect(sector).not_to receive(:update_hierarchy)

      sector.update(name: 'new name')
    end

    context 'when cascade: false' do
      it 'updates the hierarchy of the record' do
        sector.save
        first_hierarchy = sector.reload.hierarchy

        sector.district = @district
        sector.update_hierarchy

        second_hierarchy = sector.reload.hierarchy

        expect(first_hierarchy).not_to eq second_hierarchy
      end

      it 'does not update the hierarchy of the record\'s desecedants' do
        sector.save
        cell = FactoryBot.create(:cell, sector: sector)

        first_hierarchy = cell.hierarchy

        sector.district = @district
        sector.update_hierarchy

        second_hierarchy = cell.reload.hierarchy

        expect(first_hierarchy).to eq second_hierarchy
      end
    end

    context 'when cascade: true' do
      it 'updates the hierarchy of all the sector\'s desecedants' do
        sector.save
        cell = FactoryBot.create(:cell, sector: sector)

        first_hierarchy = cell.hierarchy

        sector.district = @district
        sector.update_hierarchy(cascade: true)

        second_hierarchy = cell.reload.hierarchy

        expect(first_hierarchy).not_to eq second_hierarchy
      end
    end
  end

  describe '#toggle_relations' do
    it 'is called from after_save' do
      sector.save
      sector.hidden = true

      expect(sector).to receive(:toggle_relations)

      sector.save
    end

    it 'is only called if hidden changes' do
      sector.save

      sector.name = 'New Name'

      expect(sector).not_to receive(:toggle_relations)

      sector.save
    end
  end

  context 'when record is being hidden' do
    it 'makes all desecedants hidden' do
      sector.save
      3.times do
        FactoryBot.create(:cell, hidden: false, sector: sector)
      end

      expect(sector.cells.visible.size).to eq 3

      sector.hidden = true
      sector.save

      expect(sector.cells.visible.size).to eq 0
      expect(sector.cells.hidden.size).to eq 3
    end
  end

  context 'when record is being made visible' do
    it 'makes all desecedants visible' do
      sector.hidden = true
      sector.save
      3.times do
        FactoryBot.create(:cell, hidden: true, sector: sector)
      end

      expect(sector.cells.hidden.size).to eq 3

      sector.hidden = false
      sector.save

      expect(sector.cells.visible.size).to eq 3
      expect(sector.cells.hidden.size).to eq 0
    end

    it 'makes sure all predecessors visible' do
      sector.hidden = true
      sector.save

      sector.district.update_column(:hidden, true)
      sector.country.update_column(:hidden, true)

      expect(sector.district.hidden).to eq true
      expect(sector.country.hidden).to eq true

      sector.hidden = false

      sector.save

      expect(sector.district.hidden).to eq false
      expect(sector.country.hidden).to eq false
    end
  end
end
