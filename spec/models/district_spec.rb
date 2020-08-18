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

  describe '#cell' do
    it 'returns nil, because I need all Geography models to respond to record.cell' do
      expect(district.cell).to eq nil
    end
  end

  describe '#child_class' do
    it 'returns "Sector"' do
      expect(district.child_class).to eq 'Sector'
    end
  end

  describe '#district' do
    it 'returns itself, because I need all Geography models to respond to record.district' do
      expect(district.district).to eq district
    end
  end

  describe '#facility' do
    it 'returns nil, because I need all Geography models to respond to record.facility' do
      expect(district.facility).to eq nil
    end
  end

  describe 'self.import' do
    it 'imports a record from a CSV file' do
      FactoryBot.create(:country, gis_code: 1)
      filepath = Rails.root.join 'spec/fixtures/files/rw_districts.csv'

      expect { District.import(filepath) }.to output(/3 records created./).to_stdout
    end
  end

  describe '#parent' do
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

        expect(district.reload.related_plans.is_a?(ActiveRecord::Relation)).to eq true

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

        expect(district.reload.related_reports.is_a?(ActiveRecord::Relation)).to eq true
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

      expect(district.reload.related_stories).to include story
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

  describe '#sector' do
    it 'returns nil, because I need all Geography models to respond to record.sector' do
      expect(district.sector).to eq nil
    end
  end

  describe '#update_hierarchy' do
    before :all do
      @country = FactoryBot.create(:country)
    end

    it 'is called from after_save' do
      expect(district).to receive(:update_hierarchy)

      district.save
    end

    it 'is called if country_id changes' do
      expect(district).to receive(:update_hierarchy)

      district.update(country: @country)
    end

    it 'is not called if country_id doesn\'t change' do
      district.save

      expect(district).not_to receive(:update_hierarchy)

      district.update(name: 'new name')
    end

    context 'when cascade: false' do
      it 'updates the hierarchy of the record' do
        district.save

        first_hierarcy = district.reload.hierarchy

        district.country = @country
        district.update_hierarchy

        second_hierarchy = district.reload.hierarchy

        expect(first_hierarcy).not_to eq second_hierarchy
      end

      it 'does not update the hierarchy of the record\'s descendants' do
        district.save
        sect1 = FactoryBot.create(:sector, district: district)

        first_hierarchy = sect1.hierarchy

        district.country = @country
        district.update_hierarchy

        second_hierarchy = sect1.reload.hierarchy

        expect(first_hierarchy).to eq second_hierarchy
      end
    end

    context 'when cascade: true' do
      it 'updates the hierarchy of the cell\'s descendants' do
        district.save
        sect = FactoryBot.create(:sector, district: district)
        first_hierarchy = sect.hierarchy

        district.country = @country

        district.update_hierarchy(cascade: true)

        second_hierarchy = sect.reload.hierarchy

        expect(first_hierarchy).not_to eq second_hierarchy
      end
    end
  end

  describe '#village' do
    it 'returns nil, because I need all Geography models to respond to record.village' do
      expect(district.village).to eq nil
    end
  end

  private

  describe '#toggle_relations' do
    it 'is called from after_save' do
      district.save
      district.hidden = true

      expect(district).to receive(:toggle_relations)

      district.save
    end

    it 'is called if hidden changes' do
      district.save

      district.name = 'new name'

      expect(district).not_to receive(:toggle_relations)

      district.save
    end

    context 'when record is being hidden' do
      it 'makes all descendants hidden' do
        district.save
        3.times do
          FactoryBot.create(:sector, hidden: false, district: district)
        end

        expect(district.sectors.visible.size).to eq 3

        district.hidden = true
        district.save

        expect(district.sectors.visible.size).to eq 0
        expect(district.sectors.hidden.size).to eq 3
      end
    end

    context 'when record is being made visible' do
      it 'makes all descendants visible' do
        district.hidden = true
        district.save
        3.times do
          FactoryBot.create(:sector, hidden: true, district: district)
        end

        expect(district.sectors.hidden.size).to eq 3

        district.hidden = false
        district.save

        expect(district.sectors.visible.size).to eq 3
        expect(district.sectors.hidden.size).to eq 0
      end

      it 'makes all predecessors visible' do
        district.hidden = true
        district.save

        district.country.update_column(:hidden, true)

        district.hidden = false

        district.save

        expect(district.country.hidden).to eq false
      end
    end
  end
end
