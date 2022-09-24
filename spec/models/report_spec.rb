# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report, type: :model do
  let(:report) { build :report_village }

  describe 'has validations on' do
    let(:no_date) { build :report_village, date: nil }
    let(:no_year) { build :report_village, date: nil, year: nil }
    let(:no_month) { build :report_village, date: nil, month: nil }
    let(:no_user) { build :report_village, user: nil }
    let(:no_contract) { build :report_village, contract: nil }
    let(:no_technology) { build :report_village, technology: nil }
    let(:no_reportable) { build :report_village, reportable_type: nil, reportable_id: nil }

    it 'date' do
      no_date.valid?
      expect(no_date.errors[:date]).to match_array("can't be blank")
    end

    it 'year' do
      no_year.valid?
      expect(no_year.errors[:year]).to match_array("can't be blank")
    end

    it 'month' do
      no_month.valid?
      expect(no_month.errors[:month]).to match_array("can't be blank")
    end

    it 'user' do
      no_user.valid?
      expect(no_user.errors[:user]).to match_array('must exist')
    end

    it 'technology' do
      no_technology.valid?
      expect(no_technology.errors[:technology]).to match_array('must be provided.')
    end

    it 'reportable' do
      no_reportable.valid?
      expect(no_reportable.errors[:reportable]).to match_array('must be selected.')
    end
  end

  describe 'has scopes for types' do
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

  describe 'has scopes for dates', type: :clean_reports do
    let(:earliest) { create :report_village, date: '2019-01-01' }
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

    context '#between' do
      it 'limits results to records between two dates' do
        earliest
        early
        kinda_early
        kinda_late
        late
        latest
        range = Report.between(early.date, late.date)

        expect(range).not_to include(earliest)
        expect(range).to include(early)
        expect(range).to include(kinda_early)
        expect(range).to include(kinda_late)
        expect(range).to include(late)
        expect(range).not_to include(latest)
      end
    end
  end

  describe 'has scopes for joins' do
    let(:no_story) { create :report_village }
    let(:has_story) { create :report_village }
    let(:story) { create :story, report: has_story }
    let(:report_technology) { create :report_village }
    let(:report_engagement) { create :report_engagement }

    context '#with_plans' do
      it 'is commented out and unused' do
        expect { Report.with_plans }.to raise_error(NoMethodError)
      end
    end

    context '#with_stories' do
      it 'it only returns reports that have a story' do
        no_story
        has_story
        story
        with_stories = Report.with_stories

        expect(with_stories).to include(has_story)
        expect(with_stories).not_to include(no_story)
      end
    end

    context '#with_hours' do
      it 'only returns reports that have hours above 0' do
        report_technology
        report_engagement
        with_hours = Report.with_hours

        expect(with_hours).to include(report_engagement)
        expect(with_hours).not_to include(report_technology)
      end
    end
  end

  describe 'has general scopes' do
    let(:distribution) { create :report_village, checked: nil, distributed: 3 }
    let(:check) { create :report_village, checked: 3, distributed: nil }

    context '#distributions' do
      it 'returns only reports where distributed is not nil' do
        distribution
        check

        expect(Report.distributions).to include distribution
        expect(Report.distributions).not_to include check
      end
    end

    context '#checks' do
      it 'returns only reports where checked is not nil' do
        distribution
        check

        expect(Report.checks).to include check
        expect(Report.checks).not_to include distribution
      end
    end
  end

  describe '#details' do
    let(:tech_fam) { create :technology_family }
    let(:tech_comm) { create :technology_community }

    let(:rep_dist_fam) { create :report_village, technology: tech_fam, checked: nil, distributed: 12 }
    let(:rep_dist_comm) { create :report_facility, technology: tech_comm, checked: nil, distributed: 2 }

    let(:rep_check_fam) { create :report_village, technology: tech_fam, checked: 20, distributed: nil }
    let(:rep_check_comm) { create :report_facility, technology: tech_comm, checked: 1, distributed: nil }

    context 'for distribution reports' do
      it "includes 'distributed' in the string" do
        rep_dist_fam

        expect(rep_dist_fam.details).to include 'distributed'
      end

      it "includes the 'distributed' value in the string" do
        rep_dist_fam
        rep_dist_comm

        expect(rep_dist_fam.details).to include rep_dist_fam.distributed.to_s
        expect(rep_dist_comm.details).to include rep_dist_comm.distributed.to_s
      end
    end

    context 'for check reports' do
      it "includes 'checked' in the string" do
        rep_check_fam

        expect(rep_check_fam.details).to include 'checked'
      end

      it "includes the 'checked' value in the string" do
        rep_check_fam
        rep_check_comm

        expect(rep_check_fam.details).to include rep_check_fam.checked.to_s
        expect(rep_check_comm.details).to include rep_check_comm.checked.to_s
      end
    end

    context "when technology.scale == 'Family'" do
      it "doesn't include the word 'installed'" do
        rep_dist_fam
        rep_check_fam

        expect(rep_dist_fam.details).not_to include 'installed'
        expect(rep_check_fam.details).not_to include 'installed'
      end

      it 'provides a month and year date' do
        rep_dist_fam
        rep_check_fam

        expect(rep_dist_fam.details).to include rep_dist_fam.date.strftime('%B, %Y')
        expect(rep_check_fam.details).to include rep_check_fam.date.strftime('%B, %Y')
      end
    end

    context "when technology.scale != 'Family'" do
      it "includes the word 'installed' or 'checked'" do
        rep_dist_comm
        rep_check_comm

        expect(rep_dist_comm.details).to include 'installed'
        expect(rep_check_comm.details).to include 'checked'
      end

      it 'provides a month, day, year date' do
        expect(rep_dist_comm.details).to include rep_dist_comm.date.strftime('%B, %d, %Y')
        expect(rep_check_comm.details).to include rep_check_comm.date.strftime('%B, %d, %Y')
      end
    end

    it 'includes the technology name' do
      rep_dist_fam
      rep_dist_comm
      rep_check_fam
      rep_check_comm

      expect(rep_dist_fam.details).to include ActionController::Base.helpers.pluralize(rep_dist_fam.distributed, rep_dist_fam.technology.name)
      expect(rep_dist_comm.details).to include ActionController::Base.helpers.pluralize(rep_dist_comm.distributed, rep_dist_comm.technology.name)
      expect(rep_check_fam.details).to include ActionController::Base.helpers.pluralize(rep_check_fam.checked, rep_check_fam.technology.name)
      expect(rep_check_comm.details).to include ActionController::Base.helpers.pluralize(rep_check_comm.checked, rep_check_comm.technology.name)
    end
  end

  describe '#links' do
    before :each do
      report.save
    end

    it 'returns an SafeBuffer' do
      expect(report.links.class).to eq ActiveSupport::SafeBuffer
    end

    it 'includes an edit link' do
      expect(report.links.include?('Edit</a>')).to eq true
    end

    it 'includes a delete link' do
      expect(report.links.include?('Delete</a>')).to eq true
    end
  end

  describe '#location' do
    it 'returns a string' do
      expect(report.location.class).to eq String
    end

    it 'returns the polymorphic name and class' do
      expect(report.location.include?(report.reportable.name)).to eq true
      expect(report.location.include?(report.reportable.class.to_s)).to eq true
    end
  end

  describe '#sector_name' do
    context 'when the report geography is a sector or above' do
      let(:report_district) { create :report_district }
      let(:report_country) { create :report_country }
      let(:report_sector) { create :report_sector }

      it 'returns "N/A"' do
        expect(report_district.sector_name).to eq 'N/A'
        expect(report_country.sector_name).to eq 'N/A'
        expect(report_sector.sector_name).to eq 'N/A'
      end
    end

    context 'when the report geography is below a sector' do
      let(:report_cell) { create :report_cell }
      let(:report_village) { create :report_village }
      let(:report_facility) { create :report_facility }

      it 'returns the sector\'s name' do
        expect(report_cell.sector_name).to eq report_cell.reportable.sector.name
        expect(report_village.sector_name).to eq report_village.reportable.sector.name
        expect(report_facility.sector_name).to eq report_facility.reportable.sector.name
      end
    end
  end

  describe 'geography collection methods' do
    let(:contract) { create :contract }

    describe 'self.related_facilities' do
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

    describe 'self.related_villages' do
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

    describe 'self.related_cells' do
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

    describe 'self.related_sectors' do
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

    describe 'self.related_districts' do
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

    describe 'self.ary_of_village_ids_from_facilities' do
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

      it 'returns the village_ids of the results of self.related_facilities' do
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

    describe 'self.ary_of_cell_ids_from_villages' do
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

      it 'returns the cell_ids of the results of self.related_facilities' do
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

    describe 'self.ary_of_sector_ids_from_cells' do
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

      it 'returns the sector_ids of the results of self.related_facilities' do
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

    describe 'self.ary_of_district_ids_from_sectors' do
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

      it 'returns the district_ids of the results of self.related_sectors' do
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

  private

  describe '#flag_for_meaninglessness' do
    let(:report) { build :report_village, hours: 0, distributed: nil, checked: nil }

    it 'is triggered by before_validation' do
      expect(report).to receive(:flag_for_meaninglessness).exactly(1).times

      report.valid?
    end

    it 'only fires if hours are zero and distributed and checked are zero or nil' do
      expect(report).to receive(:flag_for_meaninglessness).exactly(2).times

      report.valid? # should fire
      report.hours = 0.1
      report.valid? # should not fire
      report.hours = 0
      report.distributed = 1
      report.valid? # should not fire
      report.distributed = 0
      report.checked = 1
      report.valid? # should not fire
      report.checked = 0
      report.valid? # should fire
    end

    context 'when technology.is_engagement?' do
      it 'adds an error to :hours' do
        report.technology = FactoryBot.create(:technology_engagement)

        report.valid?

        expect(report.errors[:hours][0]).to eq 'must be provided.'
        expect(report.errors[:distributed]).to eq []
      end
    end

    context 'when technology is not engagement' do
      it 'adds an error to :distributed' do
        report.valid?

        expect(report.errors[:distributed][0]).to eq 'or checked must be provided.'
        expect(report.errors[:hours]).to eq []
      end
    end
  end

  describe '#calculate_impact' do
    let(:report) { build :report_village }

    it 'fires on the before_save action' do
      expect(report).to receive(:calculate_impact).exactly(1).times

      report.save
    end

    context 'when distributed is nil or zero' do
      it 'returns and does nothing' do
        report.distributed = nil

        expect { report.send(:calculate_impact) }.not_to change { report.impact }

        report.distributed = 0

        expect { report.send(:calculate_impact) }.not_to change { report.impact }
      end
    end

    context 'when people is present and positive' do
      it 'sets impact to match people' do
        report.people = 25

        expect { report.send(:calculate_impact) }.to change { report.impact }.from(0).to(25)
      end
    end

    context 'when reportable_type == Facility && reportable population is present and positive' do
      it 'sets impact to match reportable.population' do
        facility = FactoryBot.create(:facility, population: 45)
        report2 = FactoryBot.build(:report_facility, reportable_id: facility.id, reportable_type: 'Facility')

        expect { report2.send(:calculate_impact) }.to change { report2.impact }.from(0).to(45)
      end
    end

    context 'when people is not present or positive AND reportable_type != Facility' do
      it 'sets impact to technology.default_impact * distributed' do
        report.technology.update(default_impact: 35)
        report.people = nil

        expect { report.send(:calculate_impact) }.to change { report.impact }.from(1).to(35)

        report.impact = 0
        report.people = 0

        expect { report.send(:calculate_impact) }.to change { report.impact }.from(0).to(35)
      end
    end
  end

  describe '#calculate_distributed_impact' do
    let(:report) { build :report_village }
    let(:report_fac) { build :report_facility }

    it 'fires on #calculate_impact' do
      expect(report).to receive(:calculate_distributed_impact).exactly(1).times

      report.send(:calculate_impact)
    end

    it 'sets the value of impact' do
      expect(report.impact).to eq 0

      report.send(:calculate_distributed_impact)

      expect(report.impact).not_to eq 0
    end

    context 'when people is present and positive' do
      it 'sets impact to equal people' do
        report.people = 5
        report.send(:calculate_distributed_impact)

        expect(report.impact).to eq report.people
      end
    end

    context 'when people is unset but reportable is a facility with a positive population' do
      it 'sets impact to eq reportable.population' do
        facility = report_fac.reportable
        facility.update(population: 8)

        report_fac.send(:calculate_distributed_impact)
        expect(report_fac.impact).to eq facility.population
      end
    end

    context 'when people is unset and reportable is not a facility' do
      it 'sets impact using the default_impact and the value of distributed' do
        # TODO
      end
    end
  end

  describe '#calculate_hours_impact' do
    let(:report) { build :report_engagement }

    it 'fires on #calculate_impact' do
      expect(report).to receive(:calculate_hours_impact).exactly(1).times

      report.send(:calculate_impact)
    end

    it 'sets the value of impact' do
      expect(report.impact).to eq 0

      report.send(:calculate_hours_impact)

      expect(report.impact).not_to eq 0
    end

    context 'when hours is present and positive' do
      it 'sets impact to people * hours' do
        report.people = 5
        report.hours = 2.0
        report.send(:calculate_hours_impact)

        expect(report.impact).to eq 10
      end
    end

    context 'when hours is not present or positive' do
      it 'sets the impact to people' do
        report.people = 7
        report.hours = 0
        report.send(:calculate_hours_impact)

        expect(report.impact).to eq 7
      end
    end
  end

  describe '#set_date_from_year_and_month' do
    let(:report) { build :report_village, date: nil, year: 2020, month: 1 }

    context 'when date is blank and year and month are present' do
      it 'fires from before_validation' do
        expect(report).to receive(:set_date_from_year_and_month).exactly(1).times

        report.valid?
      end
    end

    context 'when date is present and year and month are present' do
      it 'doesn\'t fire' do
        report.date = Date.today

        expect(report).not_to receive(:set_date_from_year_and_month)

        report.valid?
      end
    end

    context 'when date is present and year and month are nil' do
      it 'doesn\'t fire' do
        report.date = Date.today
        report.year = nil
        report.month = nil

        expect(report).not_to receive(:set_date_from_year_and_month)

        report.valid?
      end
    end

    context 'when date is blank and year and month are nil' do
      it 'doesn\'t fire' do
        report.year = nil
        report.month = nil

        expect(report).not_to receive(:set_date_from_year_and_month)

        report.valid?
      end
    end

    it 'sets the date from year and month' do
      expect { report.send(:set_date_from_year_and_month) }.to change { report.date }.from(nil).to(Date.new(2020, 1, 1))
    end
  end

  describe '#set_year_and_month_from_date' do
    let(:report) { create :report_village, date: '2020-01-01' }

    context 'when date is present and changed on last save' do
      it 'fires from before_update' do
        report.date = '2019-02-01'
        expect(report).to receive(:set_year_and_month_from_date)
        report.save
      end

      it 'updates the year and month' do
        expect(report.year).to eq 2020
        expect(report.month).to eq 1

        report.update(date: '2019-02-01')

        expect(report.year).to eq 2019
        expect(report.month).to eq 2
      end
    end

    context 'when date is present but not changed' do
      it 'doesn\'t fire' do
        expect(report).not_to receive(:set_year_and_month_from_date)

        report.save
      end
    end
  end

  describe '#set_contract_from_date' do
    let(:report) { build :report_village, date: Date.today, contract_id: nil }
    let(:contract) { create :contract, start_date: Date.today - 3.days, end_date: Date.today + 3.days }

    context 'when contract_id is blank and date is present' do
      it 'fires from before_save' do
        expect(report).to receive(:set_contract_from_date).exactly(1).times

        report.save
      end
    end

    context 'when contract_id is present and date is present' do
      it 'doesn\'t fire' do
        report.contract_id = contract.id
        expect(report).not_to receive(:set_contract_from_date)

        report.save
      end
    end

    context 'when contract_id is present and date is blank' do
      it 'doesn\'t fire' do
        report.contract_id = contract.id
        report.date = nil
        expect(report).not_to receive(:set_contract_from_date)

        report.save
      end
    end

    context 'when contract_id is blank and date is blank' do
      it 'doesn\'t fire' do
        report.date = nil
        expect(report).not_to receive(:set_contract_from_date)

        report.save
      end
    end

    it 'finds the first contract that encompasses the date of the report' do
      contract
      expect { report.send(:set_contract_from_date) }.to change { report.contract_id }.from(nil).to(contract.id)
    end
  end

  describe '#set_plan' do
    context 'on new records' do
      let(:contract) { create :contract }
      let(:report) { build :report_village, contract: contract }

      it 'fires on before_save' do
        expect(report.new_record?).to eq true
        expect(report).to receive(:set_plan).exactly(1).times

        report.save
      end
    end

    context 'on persistent records' do
      let(:contract) { create :contract }
      let(:report) { create :report_village, contract: contract }

      it 'fires on before_save' do
        report.impact = 25

        expect(report.persisted?).to eq true
        expect(report).to receive(:set_plan).exactly(1).times

        report.save
      end
    end

    context 'when a matching plan is found' do
      let(:contract) { create :contract }
      let(:new_report) { build :report_village, contract: contract }
      let(:existing_report) { create :report_village, contract: contract }

      it 'sets the plan_id' do
        new_plan = FactoryBot.create(:plan_village, contract: contract, technology: new_report.technology, planable: new_report.reportable)
        existing_plan = FactoryBot.create(:plan_village, contract: contract, technology: existing_report.technology, planable: existing_report.reportable)

        expect { new_report.send(:set_plan) }.to change { new_report.plan_id }.from(nil).to(new_plan.id)
        expect { existing_report.send(:set_plan) }.to change { existing_report.plan_id }.from(nil).to(existing_plan.id)
      end
    end

    context 'when no matching plan is found' do
      let(:plan) { create :plan_village }
      let(:new_report) { build :report_village }
      let(:existing_report) { create :report_village }

      it 'does not set the plan_id' do
        expect { new_report.send(:set_plan) }.not_to change { new_report.plan_id }
        expect { existing_report.send(:set_plan) }.not_to change { existing_report.plan_id }
      end
    end
  end

  describe '#update_hierarchy' do
    before :each do
      report.save
    end

    context 'when reportable did not change' do
      it 'doesn\'t fire' do
        report.save
        expect(report).not_to receive(:update_hierarchy)

        report.save
      end
    end

    context 'when reportable changed on last save' do
      before :each do
        @village = FactoryBot.create(:village)
      end

      it 'fires from after_save' do
        expect(report).to receive(:update_hierarchy)
        report.update(reportable: @village)
      end

      it 'updates the hierarchy' do
        first_hierarchy = report.hierarchy

        report.update(reportable: @village)

        second_hierarchy = report.reload.hierarchy

        expect(first_hierarchy).not_to eq second_hierarchy
      end
    end
  end

  describe 'email notification for first report of month' do

    # before/after needed as email sent on after_commit hook. RSpec wraps examples (it) in transaction. after_commit would otherwise not be called.

    before :context do
      Report.destroy_all
      @admin   = User.admins.any? ? User.admins.first : create(:user_admin)
      contract = create :contract
      @report  = create :report_village, contract: contract
    end

    after :context do
      Report.destroy_all
      Plan.destroy_all
      Target.destroy_all
      Contract.destroy_all
      Technology.destroy_all
      User.destroy_all
    end

    it 'sends email after report created' do
      report_email = ActionMailer::Base.deliveries.find { |email| email.subject.include? 'First Report' }

      expect(report_email.to.first).to eql(@admin.email)
    end
  end
end
