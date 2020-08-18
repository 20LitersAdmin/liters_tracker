# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Facility, type: :model do
  let(:facility) { build :facility }

  context 'has validations on' do
    let(:no_name) { build :facility, name: nil }
    let(:no_village) { build :facility, village: nil }
    let(:bad_village) { build :facility, village_id: 999 }
    let(:no_category) { build :facility, category: nil }
    let(:bad_category) { build :facility, category: 'notgood' }

    it 'name' do
      no_name.valid?

      expect(no_name.errors[:name]).to match_array("can't be blank")

      no_name.name = 'has a name'
      no_name.valid?

      expect(no_name.errors.any?).to eq false
    end

    it 'village' do
      no_village.valid?
      expect(no_village.errors[:village]).to match_array('must be selected.')

      bad_village.valid?
      expect(bad_village.errors[:village]).to match_array('must be selected.')
    end

    it 'category' do
      no_category.valid?
      expect(no_category.errors[:category][0]).to include('must be one of these:')

      bad_category.valid?
      expect(bad_category.errors[:category][0]).to include('must be one of these:')
    end
  end

  context 'uses scopes to limit records' do
    let(:church) { create :facility, category: 'Church' }
    let(:school) { create :facility, category: 'School' }
    let(:clinic) { create :facility, category: 'Clinic' }
    let(:other) { create :facility, category: 'Other' }

    it "'churches' returns all facilities where the category is 'Church'" do
      expect(Facility.churches).to include church

      expect(Facility.churches).not_to include school
      expect(Facility.churches).not_to include clinic
      expect(Facility.churches).not_to include other
    end

    it "'not_churches' returns all facilities where the category is not 'Church'" do
      expect(Facility.not_churches).not_to include church

      expect(Facility.not_churches).to include school
      expect(Facility.not_churches).to include clinic
      expect(Facility.not_churches).to include other
    end
  end

  describe '#cells' do
    it 'returns sibling cells of the same sector' do
      facility.save
      3.times do
        FactoryBot.create(:cell, sector: facility.sector)
      end

      expect(facility.cells.size).to eq 4
    end
  end

  describe '#districts' do
    it 'returns sibling cells of the same country' do
      facility.save
      3.times do
        FactoryBot.create(:district, country: facility.country)
      end

      expect(facility.districts.size).to eq 4
    end
  end

  describe '#facility' do
    it 'returns itself, because I need all Geography models to respond to record.facility' do
      expect(facility.facility).to eq facility
    end
  end

  describe '#facilities' do
    it 'returns sibling records of the same village' do
      facility.save
      3.times do
        FactoryBot.create(:facility, village: facility.village)
      end

      expect(facility.facilities.size).to eq 4
    end
  end

  describe '#impact' do
    it 'returns an integer' do
      expect(facility.impact.is_a?(Integer)).to eq true
    end

    it 'combines population, households and HOUSEHOLD_SIDE' do
      facility.update(population: 4, households: 2)
      # HOUSEHOLD_SIZE = 5

      expect(facility.impact).to eq 14
    end
  end

  describe '#parent' do
    it 'returns the parent record' do
      expect(facility.parent.class).to eq Village
      expect(facility.parent).to eq facility.village
    end
  end

  describe '#related_reports' do
    it 'returns reports, because I need all Geography models to respond to record.related_reports' do
      facility.save
      3.times do
        FactoryBot.create(:report_facility, reportable: facility)
      end

      expect(facility.related_reports.size).to eq 3
      expect(facility.related_reports).to eq facility.reports
    end
  end

  describe '#related_plans' do
    it 'returns plans, because I need all Geography models to respond to record.related_plans' do
      facility.save
      3.times do
        FactoryBot.create(:plan_facility, planable: facility)
      end

      expect(facility.related_plans.size).to eq 3
      expect(facility.related_plans).to eq facility.plans
    end
  end

  describe '#related_stories' do
    it 'returns stories related to the given record' do
      facility.save
      report = FactoryBot.create(:report_facility, reportable: facility)
      story = FactoryBot.create(:story, report: report)

      expect(facility.related_stories).to include story
    end
  end

  describe '#sectors' do
    it 'returns the sibling records of the same district' do
      facility.save
      3.times do
        FactoryBot.create(:sector, district: facility.district)
      end

      expect(facility.sectors.size).to eq 4
    end
  end

  describe '#similar_by_name' do
    before :each do
      facility.name = 'key word church clinic school'
      facility.save
    end

    it 'returns a group of facilities that share a common name word' do
      similar1 = FactoryBot.create(:facility, name: 'place name key')
      similar2 = FactoryBot.create(:facility, name: 'word to your mother')
      similar3 = FactoryBot.create(:facility, name: 'sword in the keystone')

      expect(facility.similar_by_name).to include similar1
      expect(facility.similar_by_name).to include similar2
      expect(facility.similar_by_name).to include similar3
    end

    it 'ignores words found in Constants::Facility::NAME_STRIP' do
      dissimilar1 = FactoryBot.create(:facility, name: 'place name church')
      dissimilar2 = FactoryBot.create(:facility, name: 'school your mother')
      dissimilar3 = FactoryBot.create(:facility, name: 'a clinic for doctors only')

      expect(facility.similar_by_name).not_to include dissimilar1
      expect(facility.similar_by_name).not_to include dissimilar2
      expect(facility.similar_by_name).not_to include dissimilar3
    end
  end

  describe '#update_hierarchy' do
    before :all do
      @village = FactoryBot.create(:village)
    end

    it 'is called from after_save' do
      expect(facility).to receive(:update_hierarchy)

      facility.save
    end

    it 'is called if village_id changes' do
      expect(facility).to receive(:update_hierarchy)

      facility.update(village: @village)
    end

    it 'is not called if village_id doesn\'t change' do
      facility.save

      expect(facility).not_to receive(:update_hierarchy)

      facility.update(name: 'new name')
    end
  end

  describe '#villages' do
    it 'returns the sibling records of the same cell' do
      facility.save
      3.times do
        FactoryBot.create(:village, cell: facility.cell)
      end

      expect(facility.villages.size).to eq 4
    end
  end
end
