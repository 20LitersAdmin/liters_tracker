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

  describe '#cells' do
    it 'returns sibling cells of the same sector' do
      village.save
      3.times do
        FactoryBot.create(:cell, sector: village.sector)
      end

      expect(village.cells.size).to eq 4
    end
  end

  describe '#child_class' do
    it 'returns "Facility"' do
      expect(village.child_class).to eq 'Facility'
    end
  end

  describe '#districts' do
    before :all do
      District.destroy_all
    end

    it 'returns siblings of the village\'s districts' do
      village.save
      3.times do
        FactoryBot.create(:district, country: village.district.country)
        FactoryBot.create(:district)
      end

      expect(District.all.size).to eq 7
      expect(village.districts.size).to eq 4
    end
  end

  describe '#facility' do
    it 'returns nil' do
      expect(village.facility).to eq nil
    end
  end

  describe 'self.import' do
    it 'imports records from a CSV file' do
      FactoryBot.create(:cell, gis_code: 110_101)
      filepath = Rails.root.join 'spec/fixtures/files/rw_villages.csv'

      expect { Village.import(filepath) }.to output(/3 records created./).to_stdout
    end
  end

  describe '#parent' do
    it 'returns the parent object' do
      expect(village.parent).to eq village.cell
    end
  end

  describe '#pop_hh' do
    it 'displays a string with the population and household' do
      village.update(population: 10, households: 3)

      expect(village.pop_hh).to eq '10 / 3'
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
    before :each do
      village.save
    end

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
    before :each do
      village.save
    end

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

  describe '#sectors' do
    before :all do
      Sector.destroy_all
    end

    it 'returns the siblings of the village\'s parent sector' do
      village.save
      3.times do
        FactoryBot.create(:sector, district: village.sector.district)
        FactoryBot.create(:sector)
      end

      expect(Sector.all.size).to eq 7
      expect(village.sectors.size).to eq 4
    end
  end

  describe '#village' do
    it 'returns itself because I need all geography records to respond to all possible geographies' do
      village.save
      expect(village.village).to eq village
    end
  end

  describe '#villages' do
    it 'returns the sibling records of the same cell' do
      village.save
      3.times do
        FactoryBot.create(:village, cell: village.cell)
      end

      expect(village.villages.size).to eq 4
    end
  end

  describe '#update_hierarchy' do
    before :each do
      @cell = create(:cell)
    end

    it 'is called from after_save' do
      expect(village).to receive(:update_hierarchy)

      village.save
    end

    it 'is called if cell_id changes' do
      expect(village).to receive(:update_hierarchy)

      village.update(cell: @cell)
    end

    it 'is not called if cell_id doesn\'t change' do
      village.save

      expect(village).not_to receive(:update_hierarchy)

      village.update(name: 'new name')
    end

    context 'when cascade: false' do
      it 'updates the hierarchy of the record' do
        village.save
        first_hierarchy = village.reload.hierarchy

        village.cell = @cell
        village.update_hierarchy

        second_hierarchy = village.reload.hierarchy

        expect(first_hierarchy).not_to eq second_hierarchy
      end

      it 'does not update the hierarchy of the record\'s desecedants' do
        village.save
        fac = FactoryBot.create(:facility, village: village)

        first_hierarchy = fac.hierarchy

        village.cell = @cell
        village.update_hierarchy

        second_hierarchy = fac.reload.hierarchy

        expect(first_hierarchy).to eq second_hierarchy
      end
    end

    context 'when cascade: true' do
      it 'updates the hierarchy of all the village\'s desecedants' do
        village.save
        fac = create(:facility, village: village)
        first_hierarchy = fac.hierarchy

        village.cell = @cell

        village.update_hierarchy(cascade: true)

        second_hierarchy = fac.reload.hierarchy

        expect(first_hierarchy).not_to eq second_hierarchy
      end
    end
  end
end
