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

  describe '#related_plans' do
    before :each do
      sector.save
    end

    it 'returns plans directly related to the record' do
      plan = FactoryBot.create(:plan_sector, planable: sector)

      expect(sector.related_plans).to include plan
    end

    it 'returns plans related to child cells' do
      cell = FactoryBot.create(:cell, sector: sector)
      plan = FactoryBot.create(:plan_cell, planable: cell)

      expect(sector.related_plans).to include plan
    end

    it 'returns plans related to child villages' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      plan = FactoryBot.create(:plan_village, planable: village)

      expect(sector.related_plans).to include plan
    end

    it 'returns plans related to child facilities' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      facility = FactoryBot.create(:facility, village: village)
      plan = FactoryBot.create(:plan_facility, planable: facility)

      expect(sector.related_plans).to include plan
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

      expect(sector.related_reports).to include report
    end

    it 'returns reports related to child villages' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      report = FactoryBot.create(:report_village, reportable: village)

      expect(sector.related_reports).to include report
    end

    it 'returns reports related to child facilities' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      facility = FactoryBot.create(:facility, village: village)
      report = FactoryBot.create(:report_facility, reportable: facility)

      expect(sector.related_reports).to include report
    end
  end

  describe '#related_stories' do
    before :each do
      sector.save
    end

    it 'returns stories directly related to the record' do
      report = FactoryBot.create(:report_sector, reportable: sector)
      story = FactoryBot.create(:story, report: report)

      expect(sector.related_stories).to include story
    end

    it 'returns stories related to child cells' do
      cell = FactoryBot.create(:cell, sector: sector)
      report = FactoryBot.create(:report_cell, reportable: cell)
      story = FactoryBot.create(:story, report: report)

      expect(sector.related_stories).to include story
    end

    it 'returns stories related to child villages' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      report = FactoryBot.create(:report_village, reportable: village)
      story = FactoryBot.create(:story, report: report)

      expect(sector.related_stories).to include story
    end

    it 'returns stories related to child facilities' do
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      facility = FactoryBot.create(:facility, village: village)
      report = FactoryBot.create(:report_facility, reportable: facility)
      story = FactoryBot.create(:story, report: report)

      expect(sector.related_stories).to include story
    end
  end
end
