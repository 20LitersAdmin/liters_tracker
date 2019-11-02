# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report, type: :model do
  context 'has validations on' do
    let(:no_date) { build :report_village, date: nil }
    let(:no_user) { build :report_village, user: nil }
    let(:no_contract) { build :report_village, contract: nil }
    let(:no_technology) { build :report_village, technology: nil }
    let(:no_reportable) { build :report_village, reportable_type: nil, reportable_id: nil }

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

    it 'reportable' do
      no_reportable.valid?
      expect(no_reportable.errors[:reportable_id]).to match_array("can't be blank")
      expect(no_reportable.errors[:reportable_type]).to match_array("can't be blank")
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
    let(:contract) { create :contract }

    context '#related_facilities' do
      let(:related_facility1) { create :facility }
      let(:related_facility2) { create :facility }
      let(:related_facility3) { create :facility }
      let(:unrelated_facility1) { create :facility }
      let(:unrelated_facility2) { create :facility }
      let(:unrelated_facility3) { create :facility }
      let(:related_report1) { create :report_facility, contract: contract, reportable: related_facility1 }
      let(:related_report2) { create :report_facility, contract: contract, reportable: related_facility2 }
      let(:related_report3) { create :report_facility, contract: contract, reportable: related_facility3 }
      let(:unrelated_report1) { create :report_district, contract: contract }
      let(:unrelated_report2) { create :report_facility, reportable: related_facility1 }
      let(:unrelated_report3) { create :report_facility, reportable: unrelated_facility1 }

      it 'returns a collection of facilities from a collection of reports' do
        related_report1
        related_report2
        related_report3
        unrelated_report1
        unrelated_report2
        unrelated_report3

        collection = contract.reports

        expect(collection.related_facilities).to include related_facility1
        expect(collection.related_facilities).to include related_facility2
        expect(collection.related_facilities).to include related_facility3

        expect(collection.related_facilities).not_to include unrelated_facility1
        expect(collection.related_facilities).not_to include unrelated_facility2
        expect(collection.related_facilities).not_to include unrelated_facility3
      end

      it 'returns an empty ActiveRecord::Relation if none are found' do
        related_report1.delete
        related_report2.delete
        related_report3.delete
        unrelated_report1
        unrelated_report2
        unrelated_report3

        collection = contract.reports

        expect(collection.related_facilities.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.related_facilities.empty?).to eq true
      end
    end

    context '#related_villages' do
      let(:related_village) { create :village }
      let(:related_facility1) { create :facility, village: related_village }
      let(:related_facility2) { create :facility, village: related_village }
      let(:related_facility3) { create :facility, village: related_village }
      let(:related_village1) { create :village }
      let(:related_village2) { create :village }
      let(:related_village3) { create :village }
      let(:unrelated_village1) { create :village }
      let(:unrelated_village2) { create :village }
      let(:unrelated_village3) { create :village }
      let(:related_report1) { create :report_facility, contract: contract, reportable: related_facility1 }
      let(:related_report2) { create :report_facility, contract: contract, reportable: related_facility2 }
      let(:related_report3) { create :report_facility, contract: contract, reportable: related_facility3 }
      let(:related_report4) { create :report_village, contract: contract, reportable: related_village1 }
      let(:related_report5) { create :report_village, contract: contract, reportable: related_village2 }
      let(:related_report6) { create :report_village, contract: contract, reportable: related_village3 }
      let(:unrelated_report1) { create :report_district, contract: contract }
      let(:unrelated_report2) { create :report_facility, reportable: related_facility1 }
      let(:unrelated_report3) { create :report_village, reportable: unrelated_village1 }

      it 'returns a collection of villages from a collection of reports' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        related_report6
        unrelated_report1
        unrelated_report2
        unrelated_report3

        collection = contract.reports

        expect(collection.related_villages).to include related_village
        expect(collection.related_villages).to include related_village1
        expect(collection.related_villages).to include related_village2
        expect(collection.related_villages).to include related_village3

        expect(collection.related_villages).not_to include unrelated_village1
        expect(collection.related_villages).not_to include unrelated_village2
        expect(collection.related_villages).not_to include unrelated_village3
      end

      it 'returns an empty ActiveRecord::Relation if none are found' do
        related_report1.delete
        related_report2.delete
        related_report3.delete
        related_report4.delete
        related_report5.delete
        related_report6.delete
        unrelated_report1
        unrelated_report2
        unrelated_report3

        collection = contract.reports

        expect(collection.related_villages.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.related_villages.empty?).to eq true
      end
    end

    context '#related_cells' do
      let(:related_cell) { create :cell }
      let(:related_cell1) { create :cell }
      let(:related_cell2) { create :cell }
      let(:related_village) { create :village, cell: related_cell }
      let(:related_facility) { create :facility, village: related_village }
      let(:unrelated_cell1) { create :cell }
      let(:unrelated_cell2) { create :cell }

      let(:related_report1) { create :report_facility, contract: contract, reportable: related_facility }
      let(:related_report2) { create :report_village, contract: contract, reportable: related_village }
      let(:related_report3) { create :report_cell, contract: contract, reportable: related_cell }
      let(:related_report4) { create :report_cell, contract: contract, reportable: related_cell1 }
      let(:related_report5) { create :report_cell, contract: contract, reportable: related_cell2 }
      let(:unrelated_report1) { create :report_district, contract: contract }
      let(:unrelated_report2) { create :report_facility, reportable: related_facility }
      let(:unrelated_report3) { create :report_cell, reportable: unrelated_cell1 }

      it 'returns a collection of cells from a collection of reports' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        unrelated_report1
        unrelated_report2
        unrelated_report3

        collection = contract.reports

        expect(collection.related_cells).to include related_cell
        expect(collection.related_cells).to include related_cell1
        expect(collection.related_cells).to include related_cell2

        expect(collection.related_cells).not_to include unrelated_cell1
        expect(collection.related_cells).not_to include unrelated_cell2
      end

      it 'returns an empty ActiveRecord::Relation if none are found' do
        related_report1.delete
        related_report2.delete
        related_report3.delete
        related_report4.delete
        related_report5.delete
        unrelated_report1
        unrelated_report2
        unrelated_report3

        collection = contract.reports

        expect(collection.related_cells.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.related_cells.empty?).to eq true
      end
    end

    context '#related_sectors' do
      let(:related_sector) { create :sector }
      let(:related_sector1) { create :sector }
      let(:related_sector2) { create :sector }
      let(:related_cell) { create :cell, sector: related_sector }
      let(:related_village) { create :village, cell: related_cell }
      let(:related_facility) { create :facility, village: related_village }
      let(:unrelated_sector1) { create :sector }
      let(:unrelated_sector2) { create :sector }

      let(:related_report1) { create :report_facility, contract: contract, reportable: related_facility }
      let(:related_report2) { create :report_village, contract: contract, reportable: related_village }
      let(:related_report3) { create :report_cell, contract: contract, reportable: related_cell }
      let(:related_report4) { create :report_sector, contract: contract, reportable: related_sector }
      let(:related_report5) { create :report_sector, contract: contract, reportable: related_sector1 }
      let(:related_report6) { create :report_sector, contract: contract, reportable: related_sector2 }
      let(:unrelated_report1) { create :report_district, contract: contract }
      let(:unrelated_report2) { create :report_facility, reportable: related_facility }
      let(:unrelated_report3) { create :report_sector, reportable: unrelated_sector1 }

      it 'returns a collection of sectors from a collection of reports' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        related_report6
        unrelated_report1
        unrelated_report2
        unrelated_report3

        collection = contract.reports

        expect(collection.related_sectors).to include related_sector
        expect(collection.related_sectors).to include related_sector1
        expect(collection.related_sectors).to include related_sector2

        expect(collection.related_sectors).not_to include unrelated_sector1
        expect(collection.related_sectors).not_to include unrelated_sector2
      end

      it 'returns an empty ActiveRecord::Relation if none are found' do
        related_report1.delete
        related_report2.delete
        related_report3.delete
        related_report4.delete
        related_report5.delete
        related_report6.delete
        unrelated_report1
        unrelated_report2
        unrelated_report3

        collection = contract.reports

        expect(collection.related_sectors.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.related_sectors.empty?).to eq true
      end
    end

    context '#related_districts' do
      let(:related_district) { create :district }
      let(:related_district1) { create :district }
      let(:related_district2) { create :district }
      let(:related_sector) { create :sector, district: related_district }
      let(:related_cell) { create :cell, sector: related_sector }
      let(:related_village) { create :village, cell: related_cell }
      let(:related_facility) { create :facility, village: related_village }
      let(:unrelated_district1) { create :district }
      let(:unrelated_district2) { create :district }

      let(:related_report1) { create :report_facility, contract: contract, reportable: related_facility }
      let(:related_report2) { create :report_village, contract: contract, reportable: related_village }
      let(:related_report3) { create :report_cell, contract: contract, reportable: related_cell }
      let(:related_report4) { create :report_sector, contract: contract, reportable: related_sector }
      let(:related_report5) { create :report_district, contract: contract, reportable: related_district }
      let(:related_report6) { create :report_district, contract: contract, reportable: related_district1 }
      let(:related_report7) { create :report_district, contract: contract, reportable: related_district2 }
      let(:unrelated_report1) { create :report_facility }
      let(:unrelated_report2) { create :report_facility, reportable: related_facility }
      let(:unrelated_report3) { create :report_district, reportable: unrelated_district1 }

      it 'returns a collection of districts from a collection of reports' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        related_report6
        related_report7
        unrelated_report1
        unrelated_report2
        unrelated_report3

        collection = contract.reports

        expect(collection.related_districts).to include related_district
        expect(collection.related_districts).to include related_district1
        expect(collection.related_districts).to include related_district2

        expect(collection.related_districts).not_to include unrelated_district1
        expect(collection.related_districts).not_to include unrelated_district2
      end

      it 'returns an empty ActiveRecord::Relation if none are found' do
        related_report1.delete
        related_report2.delete
        related_report3.delete
        related_report4.delete
        related_report5.delete
        related_report6.delete
        related_report7.delete
        unrelated_report1
        unrelated_report2
        unrelated_report3

        collection = contract.reports

        expect(collection.related_districts.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.related_districts.empty?).to eq true
      end
    end

    context '#ary_of_village_ids_from_facilities' do
      let(:related_facility1) { create :facility }
      let(:related_facility2) { create :facility }
      let(:related_facility3) { create :facility }
      let(:unrelated_facility1) { create :facility }
      let(:unrelated_facility2) { create :facility }
      let(:unrelated_facility3) { create :facility }
      let(:related_report1) { create :report_facility, contract: contract, reportable: related_facility1 }
      let(:related_report2) { create :report_facility, contract: contract, reportable: related_facility2 }
      let(:related_report3) { create :report_facility, contract: contract, reportable: related_facility3 }
      let(:unrelated_report1) { create :report_district, contract: contract }
      let(:unrelated_report2) { create :report_facility, reportable: related_facility1 }
      let(:unrelated_report3) { create :report_facility, reportable: unrelated_facility1 }

      it 'returns the village_ids of the results of #related_facilities' do
        related_report1
        related_report2
        related_report3
        unrelated_report1
        unrelated_report2
        unrelated_report3
        collection = contract.reports
        expect(collection.send(:ary_of_village_ids_from_facilities).empty?).to eq false
        expect(collection.send(:ary_of_village_ids_from_facilities)).to eq collection.related_facilities.pluck(:village_id)
      end

      it 'returns an array' do
        related_report1
        related_report2
        related_report3
        unrelated_report1
        unrelated_report2
        unrelated_report3
        collection = contract.reports
        expect(collection.send(:ary_of_village_ids_from_facilities).is_a?(Array)).to eq true
      end
    end

    context '#ary_of_cell_ids_from_villages' do
      let(:related_village) { create :village }
      let(:related_facility1) { create :facility, village: related_village }
      let(:related_facility2) { create :facility, village: related_village }
      let(:related_facility3) { create :facility, village: related_village }
      let(:related_village1) { create :village }
      let(:related_village2) { create :village }
      let(:related_village3) { create :village }
      let(:unrelated_village1) { create :village }
      let(:unrelated_village2) { create :village }
      let(:unrelated_village3) { create :village }
      let(:related_report1) { create :report_facility, contract: contract, reportable: related_facility1 }
      let(:related_report2) { create :report_facility, contract: contract, reportable: related_facility2 }
      let(:related_report3) { create :report_facility, contract: contract, reportable: related_facility3 }
      let(:related_report4) { create :report_village, contract: contract, reportable: related_village1 }
      let(:related_report5) { create :report_village, contract: contract, reportable: related_village2 }
      let(:related_report6) { create :report_village, contract: contract, reportable: related_village3 }
      let(:unrelated_report1) { create :report_district, contract: contract }
      let(:unrelated_report2) { create :report_facility, reportable: related_facility1 }
      let(:unrelated_report3) { create :report_village, reportable: unrelated_village1 }

      it 'returns the cell_ids of the results of #related_facilities' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        related_report6
        unrelated_report1
        unrelated_report2
        unrelated_report3
        collection = contract.reports

        expect(collection.send(:ary_of_cell_ids_from_villages).empty?).to eq false
        expect(collection.send(:ary_of_cell_ids_from_villages)).to eq collection.related_villages.pluck(:cell_id)
      end

      it 'returns an array' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        related_report6
        unrelated_report1
        unrelated_report2
        unrelated_report3
        collection = contract.reports
        expect(collection.send(:ary_of_cell_ids_from_villages).is_a?(Array)).to eq true
      end
    end

    context '#ary_of_sector_ids_from_cells' do
      let(:related_cell) { create :cell }
      let(:related_cell1) { create :cell }
      let(:related_cell2) { create :cell }
      let(:related_village) { create :village, cell: related_cell }
      let(:related_facility) { create :facility, village: related_village }
      let(:unrelated_cell1) { create :cell }
      let(:unrelated_cell2) { create :cell }

      let(:related_report1) { create :report_facility, contract: contract, reportable: related_facility }
      let(:related_report2) { create :report_village, contract: contract, reportable: related_village }
      let(:related_report3) { create :report_cell, contract: contract, reportable: related_cell }
      let(:related_report4) { create :report_cell, contract: contract, reportable: related_cell1 }
      let(:related_report5) { create :report_cell, contract: contract, reportable: related_cell2 }
      let(:unrelated_report1) { create :report_district, contract: contract }
      let(:unrelated_report2) { create :report_facility, reportable: related_facility }
      let(:unrelated_report3) { create :report_cell, reportable: unrelated_cell1 }

      it 'returns the sector_ids of the results of #related_facilities' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        unrelated_report1
        unrelated_report2
        unrelated_report3
        collection = contract.reports
        expect(collection.send(:ary_of_sector_ids_from_cells).empty?).to eq false
        expect(collection.send(:ary_of_sector_ids_from_cells)).to eq collection.related_cells.pluck(:sector_id)
      end

      it 'returns an array' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        unrelated_report1
        unrelated_report2
        unrelated_report3
        collection = contract.reports
        expect(collection.send(:ary_of_sector_ids_from_cells).is_a?(Array)).to eq true
      end
    end

    context '#ary_of_district_ids_from_sectors' do
      let(:related_sector) { create :sector }
      let(:related_sector1) { create :sector }
      let(:related_sector2) { create :sector }
      let(:related_cell) { create :cell, sector: related_sector }
      let(:related_village) { create :village, cell: related_cell }
      let(:related_facility) { create :facility, village: related_village }
      let(:unrelated_sector1) { create :sector }
      let(:unrelated_sector2) { create :sector }

      let(:related_report1) { create :report_facility, contract: contract, reportable: related_facility }
      let(:related_report2) { create :report_village, contract: contract, reportable: related_village }
      let(:related_report3) { create :report_cell, contract: contract, reportable: related_cell }
      let(:related_report4) { create :report_sector, contract: contract, reportable: related_sector }
      let(:related_report5) { create :report_sector, contract: contract, reportable: related_sector1 }
      let(:related_report6) { create :report_sector, contract: contract, reportable: related_sector2 }
      let(:unrelated_report1) { create :report_district, contract: contract }
      let(:unrelated_report2) { create :report_facility, reportable: related_facility }
      let(:unrelated_report3) { create :report_sector, reportable: unrelated_sector1 }

      it 'returns the district_ids of the results of #related_sectors' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        related_report6
        unrelated_report1
        unrelated_report2
        unrelated_report3
        collection = contract.reports
        expect(collection.send(:ary_of_district_ids_from_sectors).empty?).to eq false
        expect(collection.send(:ary_of_district_ids_from_sectors)).to eq collection.related_sectors.pluck(:district_id)
      end

      it 'returns an array' do
        related_report1
        related_report2
        related_report3
        related_report4
        related_report5
        related_report6
        unrelated_report1
        unrelated_report2
        unrelated_report3
        collection = contract.reports
        expect(collection.send(:ary_of_district_ids_from_sectors).is_a?(Array)).to eq true
      end
    end
  end

  context 'Model processing methods' do
    before :each do
      @data = JSON.parse(file_fixture('batch_report_params_spec.json').read)
      ActionController::Parameters.permit_all_parameters = true
      @batch_params = ActionController::Parameters.new(@data)
    end

    context '#key_params_are_missing?' do
      pending 'returns false if #technology_id, #contract_id are present and #reports.count is not zero' do
        expect(Report.key_params_are_missing?(@batch_params)).to eq false
      end

      it 'returns true if #technology_id is missing' do
        expect(Report.key_params_are_missing?(@batch_params.except('technology_id'))).to eq true
      end

      it 'returns true if #contract_id is missing' do
        expect(Report.key_params_are_missing?(@batch_params.except('contract_id'))).to eq true
      end

      it 'returns true if #reports.count is zero' do
        data = JSON.parse(file_fixture('batch_report_params_no_reports_spec.json').read)
        batch_params = ActionController::Parameters.new(data)
        expect(Report.key_params_are_missing?(batch_params)).to eq true
      end
    end

    context '#batch_process' do
      it 'calls #process for each report in the param' do
        expect(Report).to receive(:process).exactly(@batch_params['reports'].count).times

        Report.batch_process(@batch_params, 1)
      end

      it 'creates multiple records' do
        FactoryBot.create(:technology_family, id: 1)
        FactoryBot.create(:user_reports, id: 1)
        FactoryBot.create(:contract, id: 4)
        13.times do |id|
          FactoryBot.create(:village, id: id + 1)
        end

        # determine meaningful records a.k.a. params get a 2 from #determine_action
        count = 0
        @batch_params['reports'].each do |report_param|
          count += 1 if report_param['distributed'].to_i.positive? || report_param['checked'].to_i.positive?
        end

        expect { Report.batch_process(@batch_params, 1) }.to change { Report.count }.by(count)
      end
    end

    context '#process' do
      it 'calls #determine_action' do
      end

      it 'returns if action == 0' do
      end

      it 'destroys the record if action == 1' do
      end

      it 'creates the record if action == 2' do
      end

      it 'updates the record if action == 3' do
      end
    end

    context '.determine_action' do
      it 'returns 0 if record is new, but meaningful params are not positive' do
      end

      it 'returns 0 if record exists and matches params' do
      end

      it 'returns 1 if record exists but params are not positive' do
      end

      it 'returns 2 if the record is new and params are positive' do
      end

      it 'returns 3 if the record exists, but params are different' do
      end
    end
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
