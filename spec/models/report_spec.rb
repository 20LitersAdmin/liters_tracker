# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report, type: :model do
  context 'has validations on' do
    let(:no_date) { build :report_village, date: nil }
    let(:no_user) { build :report_village, user: nil }
    let(:no_contract) { build :report_village, contract: nil }
    let(:no_technology) { build :report_village, technology: nil }

    it 'date' do
      no_date.valid?
      expect(no_date.errors[:date]).to match_array("can't be blank")
    end

    it 'user' do
      no_user.valid?
      expect(no_user.errors[:user]).to match_array('must exist')
      expect(no_user.errors[:user_id]).to match_array("can't be blank")
    end

    it 'contract' do
      no_contract.valid?
      expect(no_contract.errors[:contract]).to match_array('must exist')
      expect(no_contract.errors[:contract_id]).to match_array("can't be blank")
    end

    it 'technology' do
      no_technology.valid?
      expect(no_technology.errors[:technology]).to match_array('must exist')
      expect(no_technology.errors[:technology_id]).to match_array("can't be blank")
    end
  end

  context 'has scopes for types' do
    let(:report_district) { create :report_district }
    let(:report_sector) { create :report_sector }
    let(:report_cell) { create :report_cell }
    let(:report_village) { create :report_village }
    let(:report_facility) { create :report_facility }


    context '#only_districts' do
      it 'returns a collection of Reports where the reportable_type is district' do
        expect(Report.only_districts).to include report_district
        expect(Report.only_districts).not_to include report_sector
        expect(Report.only_districts).not_to include report_cell
        expect(Report.only_districts).not_to include report_village
        expect(Report.only_districts).not_to include report_facility
      end
    end

    context '#only_sectors' do
      it 'returns a collection of Reports where the reportable_type is sector' do
        expect(Report.only_sectors).not_to include report_district
        expect(Report.only_sectors).to include report_sector
        expect(Report.only_sectors).not_to include report_cell
        expect(Report.only_sectors).not_to include report_village
        expect(Report.only_sectors).not_to include report_facility
      end
    end

    context '#only_cells' do
      it 'returns a collection of Reports where the reportable_type is cell' do
        expect(Report.only_cells).not_to include report_district
        expect(Report.only_cells).not_to include report_sector
        expect(Report.only_cells).to include report_cell
        expect(Report.only_cells).not_to include report_village
        expect(Report.only_cells).not_to include report_facility
      end
    end

    context '#only_villages' do
      it 'returns a collection of Reports where the reportable_type is village' do
        expect(Report.only_villages).not_to include report_district
        expect(Report.only_villages).not_to include report_sector
        expect(Report.only_villages).not_to include report_cell
        expect(Report.only_villages).to include report_village
        expect(Report.only_villages).not_to include report_facility
      end
    end

    context '#only_facilities' do
      it 'returns a collection of Reports where the reportable_type is facility' do
        expect(Report.only_facilities).not_to include report_district
        expect(Report.only_facilities).not_to include report_sector
        expect(Report.only_facilities).not_to include report_cell
        expect(Report.only_facilities).not_to include report_village
        expect(Report.only_facilities).to include report_facility
      end
    end
  end

  context 'has scopes for dates' do
    let(:earliest) { create :report_village, date: Date.today - 3.years }
    let(:early) { create :report_village, date: Date.today - 2.years }
    let(:kinda_early) { create :report_village, date: Date.today - 1.year }
    let(:kinda_late) { create :report_village, date: Date.today - 9.months }
    let(:late) { create :report_village, date: Date.today - 6.months }
    let(:latest) { create :report_village, date: Date.today - 3.months }

    context '#within_month' do
      it 'returns all Reports that fall within the month of the given date' do
        earliest
        early
        kinda_early
        kinda_late
        late
        latest
        date_range = (Date.today.beginning_of_month..Date.today.end_of_month).to_a

        3.times do
          FactoryBot.create(:report_village, date: date_range.sample)
        end

        expect(Report.all.size).to eq 9
        expect(Report.within_month(Date.today).size).to eq 3
      end
    end

    context '#earliest_date' do
      it 'returns the earliest record\'s date from a collection' do
        earliest
        early
        kinda_early
        kinda_late
        late
        latest
        expect(Report.earliest_date).to eq earliest.date
      end
    end

    context '#latest_date' do
      it 'returns the latest record\'s date from a collection' do
        earliest
        early
        kinda_early
        kinda_late
        late
        latest
        expect(Report.latest_date).to eq latest.date
      end
    end
  end

  context 'single geography methods' do
    let(:district) { create :district }
    let(:sector) { create :sector, district: district }
    let(:cell) { create :cell, sector: sector }
    let(:village) { create :village, cell: cell }
    let(:facility) { create :facility, village: village }

    let(:other_district) { create :district }
    let(:other_sector) { create :sector }
    let(:other_cell) { create :cell }
    let(:other_village) { create :village }
    let(:other_facility) { create :facility }

    context '#related_to' do
      let(:related_report1) { create :report_village, reportable: village }
      let(:related_report2) { create :report_village, reportable: village }
      let(:related_report3) { create :report_village, reportable: village }
      let(:unrelated_report) { create :report_village, reportable: other_village }

      it 'returns a collection of reports directly related to the given geography' do
        related_report1
        related_report2
        related_report3
        unrelated_report
        collection = Report.related_to(village)

        expect(collection).to include related_report1
        expect(collection).to include related_report2
        expect(collection).to include related_report3
        expect(collection).not_to include unrelated_report
      end

      it 'returns an empty ActiveRecord collection if no records are present' do
        collection = Report.related_to(other_village)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end
    end

    context '#related_to_facility' do
      let(:related_report1) { create :report_facility, reportable: facility }
      let(:related_report2) { create :report_facility, reportable: facility }
      let(:related_report3) { create :report_facility, reportable: facility }
      let(:unrelated_report) { create :report_facility, reportable: other_facility }

      it 'returns a collection of reports directly related to the given facility' do
        related_report1
        related_report2
        related_report3
        unrelated_report
        collection = Report.related_to_facility(facility)

        expect(collection).to include related_report1
        expect(collection).to include related_report2
        expect(collection).to include related_report3
        expect(collection).not_to include unrelated_report
      end

      it 'returns an empty ActiveRecord collection if no records are present' do
        unrelated_report.delete
        collection = Report.related_to_facility(other_facility)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end

      it 'returns an error if the record is not a facility' do
        expect { Report.related_to_facility(village) }.to raise_error RuntimeError
      end
    end

    context '#related_to_village' do
      let(:related_report1) { create :report_village, reportable: village }
      let(:related_report2) { create :report_facility, reportable: facility }
      let(:related_report3) { create :report_village, reportable: village }
      let(:unrelated_report1) { create :report_village, reportable: other_village }
      let(:unrelated_report2) { create :report_facility, reportable: other_facility }

      it 'returns a collection of reports directly related to the given village and its children' do
        related_report1
        related_report2
        related_report3
        unrelated_report1
        unrelated_report2
        collection = Report.related_to_village(village)

        expect(collection).to include related_report1
        expect(collection).to include related_report2
        expect(collection).to include related_report3
        expect(collection).not_to include unrelated_report1
        expect(collection).not_to include unrelated_report2
      end

      it 'returns an empty ActiveRecord collection if no records are present' do
        unrelated_report1.delete
        collection = Report.related_to_village(other_village)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end

      it 'returns an error if the record is not a village' do
        expect { Report.related_to_village(facility) }.to raise_error RuntimeError
      end
    end

    context '#related_to_cell' do
      let(:related_report1) { create :report_village, reportable: village }
      let(:related_report2) { create :report_facility, reportable: facility }
      let(:related_report3) { create :report_cell, reportable: cell }
      let(:unrelated_report1) { create :report_village, reportable: other_village }
      let(:unrelated_report2) { create :report_cell, reportable: other_cell }

      it 'returns a collection of reports directly related to the given cell and its children' do
        related_report1
        related_report2
        related_report3
        unrelated_report1
        unrelated_report2
        collection = Report.related_to_cell(cell)

        expect(collection).to include related_report1
        expect(collection).to include related_report2
        expect(collection).to include related_report3
        expect(collection).not_to include unrelated_report1
        expect(collection).not_to include unrelated_report2
      end

      it 'returns an empty ActiveRecord collection if no records are present' do
        unrelated_report2.delete
        collection = Report.related_to_cell(other_cell)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end

      it 'returns an error if the record is not a cell' do
        expect { Report.related_to_cell(district) }.to raise_error RuntimeError
      end
    end

    context '#related_to_sector' do
      let(:related_report1) { create :report_village, reportable: village }
      let(:related_report2) { create :report_facility, reportable: facility }
      let(:related_report3) { create :report_cell, reportable: cell }
      let(:related_report4) { create :report_sector, reportable: sector }
      let(:unrelated_report1) { create :report_village, reportable: other_village }
      let(:unrelated_report2) { create :report_sector, reportable: other_sector }

      it 'returns a collection of reports directly related to the given sector and its children' do
        related_report1
        related_report2
        related_report3
        related_report4
        unrelated_report1
        unrelated_report2
        collection = Report.related_to_sector(sector)

        expect(collection).to include related_report1
        expect(collection).to include related_report2
        expect(collection).to include related_report3
        expect(collection).to include related_report4
        expect(collection).not_to include unrelated_report1
        expect(collection).not_to include unrelated_report2
      end

      it 'returns an empty ActiveRecord collection if no records are present' do
        unrelated_report2.delete
        collection = Report.related_to_sector(other_sector)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end

      it 'returns an error if the record is not a sector' do
        expect { Report.related_to_sector(facility) }.to raise_error RuntimeError
      end
    end

    context '#related_to_district' do
      let(:related_report1) { create :report_village, reportable: village }
      let(:related_report2) { create :report_facility, reportable: facility }
      let(:related_report3) { create :report_cell, reportable: cell }
      let(:related_report4) { create :report_sector, reportable: sector }
      let(:related_report5) { create :report_district, reportable: district }
      let(:unrelated_report1) { create :report_village, reportable: other_village }
      let(:unrelated_report2) { create :report_district, reportable: other_district }

      it 'returns a collection of reports directly related to the given district and its children' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        unrelated_report1
        unrelated_report2
        collection = Report.related_to_district(district)

        expect(collection).to include related_report1
        expect(collection).to include related_report2
        expect(collection).to include related_report3
        expect(collection).to include related_report4
        expect(collection).to include related_report5
        expect(collection).not_to include unrelated_report1
        expect(collection).not_to include unrelated_report2
      end

      it 'returns an empty ActiveRecord collection if no records are present' do
        unrelated_report2.delete
        collection = Report.related_to_district(other_district)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end

      it 'returns an error if the record is not a district' do
        expect { Report.related_to_district(cell) }.to raise_error RuntimeError
      end
    end
  end

  context 'geography collection methods' do


    context '#related_facilities' do
    end

    context '#related_villages' do
    end

    context '#related_cells' do
    end

    context '#related_sectors' do
    end

    context '#related_districts' do
    end

    context '#ary_of_village_ids_from_facilities' do
    end

    context '#ary_of_cell_ids_from_villages' do
    end

    context '#ary_of_sector_ids_from_cells' do
    end

    context '#ary_of_district_ids_from_sectors' do
    end
  end

  context 'Model processing methods' do
    context '#key_params_are_missing?' do
    end

    context '#batch_process' do
    end

    context '#process' do
    end

    context '.determine_action'
  end

  context '.model' do
  end

  context '.people_served' do
  end

  context '.households_served' do
  end

  context '.household_impact' do
  end

  context '.impact' do
  end
end
