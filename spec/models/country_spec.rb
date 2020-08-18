# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Country, type: :model do
  let(:country) { build :country }

  describe 'has validations on' do
    let(:no_name) { build :country, name: nil }
    let(:no_gis) { build :country, gis_code: nil }
    let(:duplicate_gis) { build :country }

    context 'name' do
      it 'must be present' do
        no_name.valid?

        expect(no_name.errors[:name]).to match_array("can't be blank")

        no_name.name = 'has a name'
        no_name.valid?

        expect(no_name.errors.any?).to eq false
      end
    end

    context 'gis_code' do
      it 'can be blank' do
        no_gis.valid?

        expect(no_gis.errors.any?).to eq false
      end

      it "can't be a duplicate" do
        country.update(gis_code: 1)

        duplicate_gis.gis_code = 1
        duplicate_gis.valid?

        expect(duplicate_gis.errors[:gis_code]).to match_array('has already been taken')
      end
    end
  end

  describe '#child_class' do
    it 'returns "District"' do
      expect(country.child_class).to eq 'District'
    end
  end

  describe '#country' do
    it 'returns itself, because I need all Geography models to respond to record.country' do
      expect(country.country).to eq country
    end
  end

  fdescribe '#hierarchy' do
    it 'returns an empty array' do
      expect(country.hierarchy.class).to eq Array
      expect(country.hierarchy).to eq []
    end
  end

  describe '#related_plans' do
    let!(:country2) { create :country }

    context 'when no plans exist' do
      it 'returns an empty active record object' do
        expect(country2.related_plans.is_a?(ActiveRecord::Relation))

        expect(country2.related_plans.size).to eq(0)
      end
    end

    context 'when plans exist' do
      let(:sector) { create :sector, country: country2 }
      let(:cell) { create :cell, sector: sector }
      let(:village) { create :village, cell: cell }
      let(:facility) { create :facility, village: village }

      let(:unrelated_village) { create :village }

      let(:plan1) { create :plan_village, planable_id: village.id, planable_type: 'Village' }
      let(:plan2) { create :plan_village, planable_id: village.id, planable_type: 'Village' }
      let(:plan3) { create :plan_facility, planable_id: facility.id, planable_type: 'Facility' }
      let(:plan4) { create :plan_cell, planable_id: cell.id, planable_type: 'Cell' }

      let(:unrelated_plan1) { create :plan_village, planable_id: unrelated_village.id, planable_type: 'Village' }

      it 'returns related plans in an active record object' do
        plan1
        plan2
        plan3
        plan4
        unrelated_plan1

        expect(country2.related_plans.is_a?(ActiveRecord::Relation)).to eq true

        expect(country2.related_plans.size).to eq 4
      end
    end
  end

  describe '#related_reports' do
    let!(:country2) { create :country }

    context 'when no reports exist' do
      it 'returns an empty active record object' do
        expect(country2.related_reports.is_a?(ActiveRecord::Relation))

        expect(country2.related_reports.size).to eq(0)
      end
    end

    context 'when reports exist' do
      let(:sector) { create :sector, country: country2 }
      let(:cell) { create :cell, sector: sector }
      let(:village) { create :village, cell: cell }
      let(:facility) { create :facility, village: village }

      let(:unrelated_village) { create :village }

      let(:report1) { create :report_village, reportable_id: village.id, reportable_type: 'Village' }
      let(:report2) { create :report_village, reportable_id: village.id, reportable_type: 'Village' }
      let(:report3) { create :report_facility, reportable_id: facility.id, reportable_type: 'Facility' }
      let(:report4) { create :report_cell, reportable_id: cell.id, reportable_type: 'Cell' }

      let(:unrelated_report1) { create :report_village, reportable_id: unrelated_village.id, reportable_type: 'Village' }

      it 'returns related reports in an active record object' do
        report1
        report2
        report3
        report4
        unrelated_report1

        expect(country2.related_reports.is_a?(ActiveRecord::Relation)).to eq true

        expect(country2.related_reports.size).to eq 4
      end
    end
  end

  describe '#related_stories' do
    before :each do
      country.save
    end

    it 'returns stories directly related to the record' do
      report = FactoryBot.create(:report_sector, reportable: country)
      story = FactoryBot.create(:story, report: report)

      expect(country.related_stories).to include story
    end

    it 'returns stories related to child districts' do
      district = FactoryBot.create(:district, country: country)
      sector = FactoryBot.create(:sector, district: district)
      report = FactoryBot.create(:report_sector, reportable: sector)
      story = FactoryBot.create(:story, report: report)

      expect(country.related_stories).to include story
    end

    it 'returns stories related to child sectors' do
      district = FactoryBot.create(:district, country: country)
      sector = FactoryBot.create(:sector, district: district)
      report = FactoryBot.create(:report_sector, reportable: sector)
      story = FactoryBot.create(:story, report: report)

      expect(country.related_stories).to include story
    end

    it 'returns stories related to child cells' do
      district = FactoryBot.create(:district, country: country)
      sector = FactoryBot.create(:sector, district: district)
      cell = FactoryBot.create(:cell, sector: sector)
      report = FactoryBot.create(:report_cell, reportable: cell)
      story = FactoryBot.create(:story, report: report)

      expect(country.related_stories).to include story
    end

    it 'returns stories related to child villages' do
      district = FactoryBot.create(:district, country: country)
      sector = FactoryBot.create(:sector, district: district)
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      report = FactoryBot.create(:report_village, reportable: village)
      story = FactoryBot.create(:story, report: report)

      expect(country.related_stories).to include story
    end

    it 'returns stories related to child facilities' do
      district = FactoryBot.create(:district, country: country)
      sector = FactoryBot.create(:sector, district: district)
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      facility = FactoryBot.create(:facility, village: village)
      report = FactoryBot.create(:report_facility, reportable: facility)
      story = FactoryBot.create(:story, report: report)

      expect(country.related_stories).to include story
    end
  end
end
