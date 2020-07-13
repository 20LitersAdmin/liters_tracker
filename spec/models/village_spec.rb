# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Village, type: :model do
  let(:village) { build :village }

  context 'has validations on' do
    let(:no_name) { build :village, name: nil }
    let(:no_cell) { build :village, cell: nil }
    let(:bad_cell) { build :village, cell_id: 999 }
    let(:no_gis) { build :village, gis_code: nil }
    let(:duplicate_gis) { build :village }

    it 'name' do
      no_name.valid?
      expect(no_name.errors[:name]).to match_array "can't be blank"
    end

    it 'cell' do
      no_cell.valid?
      expect(no_cell.errors[:cell_id]).to match_array "can't be blank"

      bad_cell.valid?
      expect(bad_cell.errors[:cell]).to match_array 'must exist'
    end

    context 'gis_code' do
      it 'can be blank' do
        no_gis.valid?
        expect(no_gis.errors.any?).to eq false
      end

      it "can't be duplicated" do
        village.update(gis_code: 21)
        duplicate_gis.gis_code = 21
        duplicate_gis.valid?

        expect(duplicate_gis.errors[:gis_code]).to match_array 'has already been taken'
      end
    end
  end

  describe 'child_class' do
    it 'returns "Facility"' do
      expect(village.child_class).to eq 'Facility'
    end
  end

  describe 'hierarchy' do
    it 'returns an array of hashes with name and link' do
      village.save
      hierarchy = village.hierarchy

      expect(hierarchy.is_a?(Array)).to eq true
      expect(hierarchy[0].is_a?(Hash)).to eq true
      expect(hierarchy[0]['parent_name'].present?).to eq true
      expect(hierarchy[0]['parent_type'].present?).to eq true
      expect(hierarchy[0]['link'].present?).to eq true
    end
  end

  describe 'parent' do
    it 'returns the parent object' do
      expect(village.parent).to eq village.cell
    end
  end

  describe '#related_plans' do
    before :each do
      village.save
    end

    it 'returns plans related to this village' do
      related_plan = FactoryBot.create(:plan_village, planable: village)
      unrelated_plan = FactoryBot.create(:plan_village)

      expect(village.related_plans).to include related_plan
      expect(village.related_plans).not_to include unrelated_plan
    end

    it 'returns plans related to child facilities of this village' do
      related_facility = FactoryBot.create(:facility, village: village)
      related_plan = FactoryBot.create(:plan_facility, planable: related_facility)
      unrelated_plan = FactoryBot.create(:plan_facility)

      expect(village.reload.related_plans).to include related_plan
      expect(village.related_plans).not_to include unrelated_plan
    end
  end

  describe '#related_reports' do
    it 'returns reports related to this village' do
      related_report = FactoryBot.create(:report_village, reportable: village)
      unrelated_report = FactoryBot.create(:report_village)

      expect(village.related_reports).to include related_report
      expect(village.related_reports).not_to include unrelated_report
    end

    it 'returns reports related to child facilities of this village' do
      related_facility = FactoryBot.create(:facility, village: village)
      related_report = FactoryBot.create(:report_facility, reportable: related_facility)
      unrelated_report = FactoryBot.create(:report_facility)

      expect(village.reload.related_reports).to include related_report
      expect(village.related_reports).not_to include unrelated_report
    end
  end

  describe '#related_stories' do
    it 'returns stories related to this village' do
      related_report = FactoryBot.create(:report_village, reportable: village)
      related_story = FactoryBot.create(:story, report: related_report)
      unrelated_story = FactoryBot.create(:story)

      expect(village.related_stories).to include related_story
      expect(village.related_stories).not_to include unrelated_story
    end

    it 'returns stories related to child facilities of this village' do
      related_facility = FactoryBot.create(:facility, village: village)
      related_report = FactoryBot.create(:report_facility, reportable: related_facility)
      related_story = FactoryBot.create(:story, report: related_report)
      unrelated_story = FactoryBot.create(:story)

      expect(village.reload.related_stories).to include related_story
      expect(village.related_stories).not_to include unrelated_story
    end
  end

  describe '#pop_hh' do
    it 'displays a string with the population and household' do
      village.update(population: 10, households: 3)

      expect(village.pop_hh).to eq '10 / 3'
    end
  end

  describe '#village' do
    it 'returns itself because I need all geography records to respond to all possible geographies' do
      village.save
      expect(village.village).to eq village
    end
  end
end
