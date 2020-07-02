# frozen_string_literal: true

require 'rails_helper'

RSpec.describe District, type: :model do
  let(:district) { build :district }

  context 'has validations on' do
    let(:no_name) { build :district, name: nil }
    let(:no_gis) { build :district, gis_code: nil }
    let(:duplicate_gis) { build :district }

    it 'name' do
      no_name.valid?

      expect(no_name.errors[:name]).to match_array("can't be blank")

      no_name.name = 'has a name'
      no_name.valid?

      expect(no_name.errors.any?).to eq false
    end

    context 'gis_code' do
      it 'can be blank' do
        no_gis.valid?

        expect(no_gis.errors.any?).to eq false
      end

      it "can't be a duplicate" do
        district.update(gis_code: 1)

        duplicate_gis.gis_code = 1
        duplicate_gis.valid?

        expect(duplicate_gis.errors[:gis_code]).to match_array('has already been taken')
      end
    end
  end

  describe 'child_class' do
    it 'returns "Sector"' do
      expect(district.child_class).to eq 'Sector'
    end
  end

  describe 'hierarchy' do
    it 'returns an array of hashes with name and link' do
      hierarchy = district.hierarchy

      expect(hierarchy.is_a?(Array)).to eq true
      expect(hierarchy[0].is_a?(Hash)).to eq true
      expect(hierarchy[0][:name].present?).to eq true
      expect(hierarchy[0][:link].present?).to eq true
    end
  end

  describe 'parent' do
    it 'returns the parent object' do
      expect(district.parent).to eq district.country
    end
  end

  describe '#related_plans' do
    let(:district) { create :district }

    context 'when there are no plans' do
      it 'returns an empty activerecord object' do
        expect(district.related_plans.is_a?(ActiveRecord::Relation)).to eq true
      end
    end

    context 'when there are plans' do
      let(:sector) { create :sector, district: district }
      let(:cell) { create :cell, sector: sector }
      let(:village) { create :village, cell: cell }
      let(:facility) { create :facility, village: village }

      let(:unrelated_village) { create :village }
      let(:unrelated_facility) { create :facility }

      let(:plan_sector) { create :plan_sector, planable_id: sector.id, planable_type: 'Sector' }
      let(:plan_cell) { create :plan_cell, planable_id: cell.id, planable_type: 'Cell' }
      let(:plan_village) { create :plan_village, planable_id: village.id, planable_type: 'Village' }
      let(:plan_facility) { create :plan_facility, planable_id: facility.id, planable_type: 'Facility' }

      let(:unrelated_plan_village) { create :plan_village, planable_id: unrelated_village.id, planable_type: 'Village' }
      let(:unrelated_plan_facility) { create :plan_facility, planable_id: unrelated_facility.id, planable_type: 'Facility' }

      it 'returns an activerecord object of plans' do
        plan_sector
        plan_cell
        plan_village
        plan_facility
        unrelated_plan_village
        unrelated_plan_facility

        expect(district.related_plans.is_a?(ActiveRecord::Relation)).to eq true
        expect(district.related_plans.size).to eq(4)

        expect(district.related_plans).to include(plan_sector)
        expect(district.related_plans).to include(plan_cell)
        expect(district.related_plans).to include(plan_village)
        expect(district.related_plans).to include(plan_facility)
        expect(district.related_plans).not_to include(unrelated_plan_village)
        expect(district.related_plans).not_to include(unrelated_plan_facility)
      end
    end
  end

  describe '#related_reports' do
    let(:district) { create :district }

    context 'when there are no reports' do
      it 'returns an empty activerecord object' do
        expect(district.related_reports.is_a?(ActiveRecord::Relation)).to eq true
      end
    end

    context 'when there are reports' do
      let(:sector) { create :sector, district: district }
      let(:cell) { create :cell, sector: sector }
      let(:village) { create :village, cell: cell }
      let(:facility) { create :facility, village: village }

      let(:unrelated_village) { create :village }
      let(:unrelated_facility) { create :facility }

      let(:report_sector) { create :report_sector, reportable_id: sector.id, reportable_type: 'Sector' }
      let(:report_cell) { create :report_cell, reportable_id: cell.id, reportable_type: 'Cell' }
      let(:report_village) { create :report_village, reportable_id: village.id, reportable_type: 'Village' }
      let(:report_facility) { create :report_facility, reportable_id: facility.id, reportable_type: 'Facility' }

      let(:unrelated_report_village) { create :report_village, reportable_id: unrelated_village.id, reportable_type: 'Village' }
      let(:unrelated_report_facility) { create :report_facility, reportable_id: unrelated_facility.id, reportable_type: 'Facility' }

      it 'returns an activerecord object of reports' do
        report_sector
        report_cell
        report_village
        report_facility
        unrelated_report_village
        unrelated_report_facility

        expect(district.related_reports.is_a?(ActiveRecord::Relation)).to eq true
        expect(district.related_reports.size).to eq(4)

        expect(district.related_reports).to include(report_sector)
        expect(district.related_reports).to include(report_cell)
        expect(district.related_reports).to include(report_village)
        expect(district.related_reports).to include(report_facility)
        expect(district.related_reports).not_to include(unrelated_report_village)
        expect(district.related_reports).not_to include(unrelated_report_facility)
      end
    end
  end

  describe '#related_stories' do
    before :each do
      district.save
    end

    it 'returns stories directly related to the record' do
      report = FactoryBot.create(:report_district, reportable: district)
      story = FactoryBot.create(:story, report: report)

      expect(district.related_stories).to include story
    end

    it 'returns stories related to child sectors' do
      sector = FactoryBot.create(:sector, district: district)
      report = FactoryBot.create(:report_sector, reportable: sector)
      story = FactoryBot.create(:story, report: report)

      expect(district.related_stories).to include story
    end

    it 'returns stories related to child cells' do
      sector = FactoryBot.create(:sector, district: district)
      cell = FactoryBot.create(:cell, sector: sector)
      report = FactoryBot.create(:report_cell, reportable: cell)
      story = FactoryBot.create(:story, report: report)

      expect(district.related_stories).to include story
    end

    it 'returns stories related to child villages' do
      sector = FactoryBot.create(:sector, district: district)
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      report = FactoryBot.create(:report_village, reportable: village)
      story = FactoryBot.create(:story, report: report)

      expect(district.related_stories).to include story
    end

    it 'returns stories related to child facilities' do
      sector = FactoryBot.create(:sector, district: district)
      cell = FactoryBot.create(:cell, sector: sector)
      village = FactoryBot.create(:village, cell: cell)
      facility = FactoryBot.create(:facility, village: village)
      report = FactoryBot.create(:report_facility, reportable: facility)
      story = FactoryBot.create(:story, report: report)

      expect(district.related_stories).to include story
    end
  end
end
