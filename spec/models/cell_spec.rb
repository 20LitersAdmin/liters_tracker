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

  describe 'has scopes on:' do
    before :each do
      3.times do
        FactoryBot.create(:cell, hidden: true)
        FactoryBot.create(:cell, hidden: false)
      end
    end

    context 'hidden' do
      it 'returns only cells where hidden is set to true' do
        expect(Cell.hidden.size).to eq 3
      end
    end

    context 'visible' do
      it 'returns only cells where hidden is set to false' do
        expect(Cell.visible.size).to eq 3
      end
    end
  end

  describe '#cell' do
    it 'returns itself, because I need all Geography models to respond to record.cell' do
      expect(cell.cell).to eq cell
    end
  end

  describe '#cells' do
    it 'returns sibling cells of the same sector' do
      cell.save
      3.times do
        FactoryBot.create(:cell, sector: cell.sector)
      end

      expect(cell.cells.size).to eq 4
    end
  end

  describe '#child_class' do
    it 'returns "Village"' do
      expect(cell.child_class).to eq 'Village'
    end
  end

  describe '#districts' do
    it 'returns siblings of the cell\'s districts' do
      3.times do
        FactoryBot.create(:district, country: cell.district.country)
        FactoryBot.create(:district)
      end

      expect(District.all.size).to eq 7
      expect(cell.districts.size).to eq 4
    end
  end

  describe '#facility' do
    it 'returns nil' do
      expect(cell.facility).to eq nil
    end
  end

  describe 'self.import' do
    it 'imports records from a CSV file' do
      create(:sector, gis_code: 1101)
      filepath = Rails.root.join 'spec/fixtures/files/rw_cells.csv'

      expect { Cell.import(filepath) }.to output(/3 records created./).to_stdout
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

  describe '#sectors' do
    it 'returns the siblings of the cell\'s parent sector' do
      3.times do
        FactoryBot.create(:sector, district: cell.sector.district)
        FactoryBot.create(:sector)
      end

      expect(Sector.all.size).to eq 7
      expect(cell.sectors.size).to eq 4
    end
  end

  describe '#village' do
    it 'returns nil' do
      expect(cell.village).to eq nil
    end
  end

  describe '#update_hierarchy' do
    before :each do
      @sector = create(:sector)
    end

    it 'is called from after_save' do
      expect(cell).to receive(:update_hierarchy)

      cell.save
    end

    it 'is called if sector_id changes' do
      expect(cell).to receive(:update_hierarchy)

      cell.update(sector: @sector)
    end

    it 'is not called if sector_id doesn\'t change' do
      cell.save

      expect(cell).not_to receive(:update_hierarchy)

      cell.update(name: 'new name')
    end

    context 'when cascade: false' do
      it 'updates the hierarchy of the record' do
        cell.save
        first_hierarchy = cell.reload.hierarchy

        cell.sector = @sector
        cell.update_hierarchy

        second_hierarchy = cell.reload.hierarchy

        expect(first_hierarchy).not_to eq second_hierarchy
      end

      it 'does not update the hierarchy of the record\'s desecedants' do
        cell.save
        vill1 = FactoryBot.create(:village, cell: cell)

        first_hierarchy = vill1.hierarchy

        cell.sector = @sector
        cell.update_hierarchy

        second_hierarchy = vill1.reload.hierarchy

        expect(first_hierarchy).to eq second_hierarchy
      end
    end

    context 'when cascade: true' do
      it 'updates the hierarchy of all the cell\'s desecedants' do
        cell.save
        vill = FactoryBot.create(:village, cell: cell, name: 'vill1')
        first_hierarchy = vill.hierarchy

        cell.sector = @sector

        cell.update_hierarchy(cascade: true)

        second_hierarchy = vill.reload.hierarchy

        expect(first_hierarchy).not_to eq second_hierarchy
      end
    end
  end

  private

  describe '#toggle_relations' do
    it 'is called from after_save' do
      cell.save
      cell.hidden = true

      expect(cell).to receive(:toggle_relations)

      cell.save
    end

    it 'is only called if hidden changes' do
      cell.save

      cell.name = 'New Name'

      expect(cell).not_to receive(:toggle_relations)

      cell.save
    end

    context 'when record is being hidden' do
      it 'makes all desecedants hidden' do
        cell.save
        3.times do
          FactoryBot.create(:village, hidden: false, cell: cell)
        end

        expect(cell.villages.visible.size).to eq 3

        cell.hidden = true
        cell.save

        expect(cell.villages.visible.size).to eq 0
        expect(cell.villages.hidden.size).to eq 3
      end
    end

    context 'when record is being made visible' do
      it 'makes all desecedants visible' do
        cell.hidden = true
        cell.save
        3.times do
          FactoryBot.create(:village, hidden: true, cell: cell)
        end

        expect(cell.villages.hidden.size).to eq 3

        cell.hidden = false
        cell.save

        expect(cell.villages.visible.size).to eq 3
        expect(cell.villages.hidden.size).to eq 0
      end

      it 'makes sure all predecessors visible' do
        cell.hidden = true
        cell.save

        cell.sector.update_column(:hidden, true)
        cell.district.update_column(:hidden, true)
        cell.country.update_column(:hidden, true)

        expect(cell.sector.hidden).to eq true
        expect(cell.district.hidden).to eq true
        expect(cell.country.hidden).to eq true

        cell.hidden = false

        cell.save

        expect(cell.sector.hidden).to eq false
        expect(cell.district.hidden).to eq false
        expect(cell.country.hidden).to eq false
      end
    end
  end
end
