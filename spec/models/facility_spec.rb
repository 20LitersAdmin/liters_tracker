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

  describe 'hierarchy' do
    it 'returns an array of hashes with name and link' do
      facility.save
      hierarchy = facility.hierarchy

      expect(hierarchy.is_a?(Array)).to eq true
      expect(hierarchy[0].is_a?(Hash)).to eq true
      expect(hierarchy[0]['parent_name'].present?).to eq true
      expect(hierarchy[0]['parent_type'].present?).to eq true
      expect(hierarchy[0]['link'].present?).to eq true
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

  describe '#related_stories' do
    it 'returns stories related to the given record' do
      facility.save
      report = FactoryBot.create(:report_facility, reportable: facility)
      story = FactoryBot.create(:story, report: report)

      expect(facility.related_stories).to include story
    end
  end

  describe '#facility' do
    it 'returns itself because all geographies need to respond to all types of geography' do
      expect(facility.facility).to eq facility
    end
  end

  describe '#parent' do
    it 'returns the parent village' do
      expect(facility.parent).to eq facility.village
    end
  end
end
