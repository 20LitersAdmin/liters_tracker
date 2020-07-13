# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cell, type: :model do
  let(:cell) { build :cell }

  describe 'has validations on' do
    let(:no_name) { build :cell, name: nil }
    let(:no_sector) { build :cell, sector_id: nil }

    it 'name' do
      no_name.valid?
      expect(no_name.errors[:name]).to match_array("can't be blank")

      no_name.name = 'Has a name'
      no_name.valid?

      expect(no_name.errors.any?).to eq false
    end

    it 'sector_id' do
      no_sector.valid?
      expect(no_sector.errors[:sector_id]).to match_array("can't be blank")

      no_sector.sector_id = 2
      no_sector.valid?

      expect(no_sector.errors[:sector]).to match_array('must exist')

      sector = FactoryBot.create(:sector)
      no_sector.sector = sector
      no_sector.valid?

      expect(no_sector.errors.any?).to eq false
    end

    context 'gis_code which' do
      let(:duplicate_gis) { build :cell }

      it 'can be nil' do
        expect(cell.gis_code).to eq nil
        cell.valid?

        expect(cell.errors.any?).to eq false
      end

      it 'must be unique' do
        cell.update(gis_code: 1)
        duplicate_gis.gis_code = 1
        duplicate_gis.valid?

        expect(duplicate_gis.errors[:gis_code]).to match_array('has already been taken')
      end
    end
  end

  describe 'child_class' do
    it 'returns "Village"' do
      expect(cell.child_class).to eq 'Village'
    end
  end

  describe 'hierarchy' do
    it 'returns an array of hashes with name and link' do
      cell.save
      hierarchy = cell.hierarchy

      expect(hierarchy.is_a?(Array)).to eq true
      expect(hierarchy[0].is_a?(Hash)).to eq true
      expect(hierarchy[0]['parent_name'].present?).to eq true
      expect(hierarchy[0]['parent_type'].present?).to eq true
      expect(hierarchy[0]['link'].present?).to eq true
    end
  end

  describe 'parent' do
    it 'returns the parent object' do
      expect(cell.parent).to eq cell.sector
    end
  end

  describe '#related_plans' do
    let(:cell) { create :cell }

    context 'when no plans exist' do
      it 'returns an empty activerecord object' do
        expect(cell.related_plans.is_a?(ActiveRecord::Relation)).to eq true
      end
    end

    context 'when plans exist' do
      let(:village) { create :village, cell: cell }
      let(:facility) { create :facility, village: village }
      let(:unrelated_village) { create :village }
      let(:unrelated_facility) { create :facility }

      let(:plan_village) { create :plan_village, planable_id: village.id, planable_type: 'Village' }
      let(:plan_facility) { create :plan_facility, planable_id: facility.id, planable_type: 'Facility' }

      let(:unrelated_plan_village) { create :plan_village, planable_id: unrelated_village.id, planable_type: 'Village' }
      let(:unrelated_plan_facility) { create :plan_facility, planable_id: unrelated_facility.id, planable_type: 'Facility' }

      it 'returns an activerecord object' do
        plan_village
        plan_facility
        unrelated_plan_village
        unrelated_plan_facility

        expect(cell.reload.related_plans.is_a?(ActiveRecord::Relation)).to eq true
        expect(cell.related_plans.size).to eq(2)

        expect(cell.related_plans).to include(plan_village)
        expect(cell.related_plans).to include(plan_facility)
        expect(cell.related_plans).not_to include(unrelated_plan_village)
        expect(cell.related_plans).not_to include(unrelated_plan_facility)
      end
    end
  end

  describe '#related_reports' do
    let(:cell) { create :cell }

    context 'when no reports exist' do
      it 'returns an empty activerecord object' do
        expect(cell.related_reports.is_a?(ActiveRecord::Relation)).to eq true
      end
    end

    context 'when reports exist' do
      let(:village) { create :village, cell: cell }
      let(:facility) { create :facility, village: village }
      let(:unrelated_village) { create :village }
      let(:unrelated_facility) { create :facility }

      let(:report_village) { create :report_village, reportable_id: village.id, reportable_type: 'Village' }
      let(:report_facility) { create :report_facility, reportable_id: facility.id, reportable_type: 'Facility' }

      let(:unrelated_report_village) { create :report_village, reportable_id: unrelated_village.id, reportable_type: 'Village' }
      let(:unrelated_report_facility) { create :report_facility, reportable_id: unrelated_facility.id, reportable_type: 'Facility' }

      it 'returns an activerecord object' do
        report_village
        report_facility
        unrelated_report_village
        unrelated_report_facility

        expect(cell.reload.related_reports.is_a?(ActiveRecord::Relation)).to eq true
        expect(cell.related_reports.size).to eq(2)

        expect(cell.related_reports).to include(report_village)
        expect(cell.related_reports).to include(report_facility)
        expect(cell.related_reports).not_to include(unrelated_report_village)
        expect(cell.related_reports).not_to include(unrelated_report_facility)
      end
    end
  end

  describe '#related_stories' do
    before :each do
      cell.save
    end

    it 'returns stories directly related to the record' do
      report = FactoryBot.create(:report_cell, reportable: cell)
      story = FactoryBot.create(:story, report: report)

      expect(cell.reload.related_stories).to include story
    end

    it 'returns stories related to child villages' do
      village = FactoryBot.create(:village, cell: cell)
      report = FactoryBot.create(:report_village, reportable: village)
      story = FactoryBot.create(:story, report: report)

      expect(cell.reload.related_stories).to include story
    end

    it 'returns stories related to child facilities' do
      village = FactoryBot.create(:village, cell: cell)
      facility = FactoryBot.create(:facility, village: village)
      report = FactoryBot.create(:report_facility, reportable: facility)
      story = FactoryBot.create(:story, report: report)

      expect(cell.reload.related_stories).to include story
    end
  end

  describe '#cell' do
    it 'returns itself, because I need all Geography models to respond to record.cell' do
      expect(cell.cell).to eq cell
    end
  end

  describe '#village' do
    it 'returns nil' do
      expect(cell.village).to eq nil
    end
  end
end
