# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Report, type: :model do
  describe 'has validations on' do
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

  describe 'has scopes for dates' do
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

    context '#between' do
      pending 'limits results to records between two dates'
    end
  end

  describe 'has scopes for joins' do
    context '#with_plans' do
      it 'is currently unused' do
        expect(true).to eq true
      end
    end

    context '#with_stories' do
      pending 'it only returns reports that have a story'
    end
  end

  describe 'has general scopes' do
    context '#distributions' do
      pending 'returns only reports where distributed is not nil'
    end

    context '#checks' do
      it 'is currently unused' do
        expect(true).to eq true
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
      it "includes the word 'installed'" do
        rep_dist_comm
        rep_check_comm

        expect(rep_dist_comm.details).to include 'installed'
        expect(rep_check_comm.details).to include 'installed'
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

  describe 'Model processing methods' do
    before :each do
      @data = JSON.parse(file_fixture('batch_report_params_spec.json').read)
      ActionController::Parameters.permit_all_parameters = true
      @batch_params = ActionController::Parameters.new(@data)
    end

    describe '#key_params_are_missing?' do
      it 'returns false if #technology_id, #contract_id, #master_date are present and #reports.count is not zero' do
        expect(Report.key_params_are_missing?(@batch_params)).to eq false
      end

      it 'returns true if #technology_id is missing' do
        expect(Report.key_params_are_missing?(@batch_params.except('technology_id'))).to eq true
      end

      it 'returns true if #contract_id is missing' do
        expect(Report.key_params_are_missing?(@batch_params.except('contract_id'))).to eq true
      end

      it 'returns true if #master_date is missing' do
        expect(Report.key_params_are_missing?(@batch_params.except('master_date'))).to eq true
      end

      it 'returns true if #reports.count is zero' do
        data = JSON.parse(file_fixture('batch_report_params_no_reports_spec.json').read)
        batch_params = ActionController::Parameters.new(data)
        expect(Report.key_params_are_missing?(batch_params)).to eq true
      end
    end

    describe '#batch_process' do
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

    describe '#process' do
      let(:user) { create :user_reports, id: 1 }

      it 'calls #determine_action' do
        user
        allow_any_instance_of(Report).to receive(:determine_action).and_return(3)

        report_params = @batch_params[:reports][0]

        expect_any_instance_of(Report).to receive(:determine_action).and_return(3)

        Report.process(report_params, @batch_params[:technology_id], @batch_params[:contract_id], user.id, @batch_params[:master_date])
      end

      it 'returns if action == 0' do
        user
        allow_any_instance_of(Report).to receive(:determine_action).and_return(0)
        report_params = @batch_params[:reports][0]

        expect { Report.process(report_params, @batch_params[:technology_id], @batch_params[:contract_id], user.id, @batch_params[:master_date]) }.not_to change { Report.all.size }
      end

      it 'destroys the record if action == 1' do
        user
        FactoryBot.create(:technology_family, id: 1)
        FactoryBot.create(:contract, id: 4)
        FactoryBot.create(:village, id: 1)

        report_params = @batch_params[:reports][0]
        report_params[:distributed] = ''

        Report.create(
          date: report_params[:date],
          technology_id: 1,
          reportable_id: 1,
          reportable_type: 'Village',
          distributed: 5,
          checked: 5,
          user: user,
          contract_id: 4,
          people: 25
        )

        expect { Report.process(report_params, @batch_params[:technology_id], @batch_params[:contract_id], user.id, @batch_params[:master_date]) }.to change { Report.all.size }.from(1).to(0)
      end

      it 'creates the record if action == 2' do
        user
        FactoryBot.create(:technology_family, id: 1)
        FactoryBot.create(:contract, id: 4)
        FactoryBot.create(:village, id: 1)

        report_params = @batch_params[:reports][0]

        expect { Report.process(report_params, @batch_params[:technology_id], @batch_params[:contract_id], user.id, @batch_params[:master_date]) }.to change { Report.all.size }.from(0).to(1)
      end

      it 'updates the record if action == 3' do
        user
        FactoryBot.create(:technology_family, id: 1)
        FactoryBot.create(:contract, id: 4)
        FactoryBot.create(:village, id: 1)

        report_params = @batch_params[:reports][0]

        report = Report.create(
          date: report_params[:date],
          technology_id: 1,
          reportable_id: 1,
          reportable_type: 'Village',
          distributed: 2,
          user: user,
          contract_id: 4,
          people: 25
        )

        expect { Report.process(report_params, @batch_params[:technology_id], @batch_params[:contract_id], user.id, @batch_params[:master_date]) }.to change { report.reload.distributed }.from(2).to(5)
      end
    end

    describe '#determine_action' do
      before :each do
        @report_params = @batch_params[:reports][0]
        @user = FactoryBot.create(:user_reports, id: 1)
        @contract = FactoryBot.create(:contract, id: 4)
      end

      it 'returns 0 if record is new, but meaningful params are not positive' do
        @report_params[:distributed] = '0'
        @report_params[:checked] = '0'

        report = Report.new(
          date: '2019-07-01',
          technology_id: 1,
          reportable_id: 1,
          reportable_type: 'Village',
          distributed: 2,
          user_id: 1,
          contract_id: 4,
          people: 25
        )

        expect(report.new_record?).to eq true
        expect(@report_params[:distributed].to_i.positive?).to eq false
        expect(@report_params[:checked].to_i.positive?).to eq false

        expect(report.determine_action(@report_params, 4, 1)).to eq 0
      end

      it 'returns 0 if record exists and matches params' do
        FactoryBot.create(:technology_family, id: 1)
        FactoryBot.create(:village, id: 1)

        report = Report.create(
          date: '2019-07-01',
          technology_id: 1,
          reportable_id: 1,
          reportable_type: 'Village',
          distributed: 5,
          user_id: 1,
          contract_id: 4,
          people: 25
        )

        expect(report.new_record?).to eq false
        expect(report.contract_id == @contract.id).to eq true
        expect(report.user_id == @user.id).to eq true
        expect(report.distributed.to_i == @report_params[:distributed].to_i).to eq true
        expect(report.checked.to_i == @report_params[:checked].to_i).to eq true
        expect(report.people.to_i == @report_params[:people].to_i).to eq true

        expect(report.determine_action(@report_params, 4, 1)).to eq 0
      end

      it 'returns 1 if record exists but params are not positive' do
        FactoryBot.create(:technology_family, id: 1)
        FactoryBot.create(:village, id: 1)

        report = Report.create(
          date: '2019-07-01',
          technology_id: 1,
          reportable_id: 1,
          reportable_type: 'Village',
          distributed: 5,
          user_id: 1,
          contract_id: 4,
          people: 25
        )

        @report_params[:distributed] = '0'
        @report_params[:checked] = '0'

        expect(report.persisted?).to eq true
        expect(@report_params[:distributed].to_i.positive?).to eq false
        expect(@report_params[:checked].to_i.positive?).to eq false
        expect(report.determine_action(@report_params, 4, 1)).to eq 1
      end

      it 'returns 2 if the record is new and params are positive' do
        @report_params[:distributed] = '10'
        @report_params[:checked] = '2'

        report = Report.new(
          date: '2019-07-01',
          technology_id: 1,
          reportable_id: 1,
          reportable_type: 'Village',
          distributed: 2,
          user_id: 1,
          contract_id: 4,
          people: 25
        )

        expect(report.new_record?).to eq true
        expect(@report_params[:distributed].to_i.positive?).to eq true
        expect(@report_params[:checked].to_i.positive?).to eq true
        expect(report.determine_action(@report_params, 4, 1)).to eq 2
      end

      it 'returns 3 if the record exists, but params are different' do
        FactoryBot.create(:technology_family, id: 1)
        FactoryBot.create(:village, id: 1)

        report = Report.create(
          date: '2019-07-01',
          technology_id: 1,
          reportable_id: 1,
          reportable_type: 'Village',
          distributed: 5,
          checked: 1,
          user_id: 1,
          contract_id: 4,
          people: 25
        )

        @report_params[:distributed] = '10'
        @report_params[:checked] = '2'

        expect(report.persisted?).to eq true
        expect(report.distributed == @report_params[:distributed]).to eq false
        expect(report.checked == @report_params[:checked]).to eq false
        expect(report.determine_action(@report_params, 4, 1)).to eq 3
      end
    end
  end

  describe 'geography collection methods' do
    let(:contract) { create :contract }

    describe '#related_facilities' do
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

    describe '#related_villages' do
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

    describe '#related_cells' do
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

    describe '#related_sectors' do
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

    describe '#related_districts' do
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

    describe '#ary_of_village_ids_from_facilities' do
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

    describe '#ary_of_cell_ids_from_villages' do
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

    describe '#ary_of_sector_ids_from_cells' do
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

    describe '#ary_of_district_ids_from_sectors' do
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

  describe '#prevent_meaningless_reports' do
    pending 'is called on before_create'
    pending 'is called if distributed is nil'
    pending 'is called if distributed is zero'
    pending 'is called if checked is nil'
    pending 'is called if checked is zero'
    pending 'prevents a record from being created'
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

        expect { report.send(:calculate_impact) }.to change { report.impact }.from(0).to(35)

        report.impact = 0
        report.people = 0

        expect { report.send(:calculate_impact) }.to change { report.impact }.from(0).to(35)
      end
    end
  end

  describe '#set_year_and_month_from_date' do
    context 'with new records' do
      pending 'fires on before_save'
    end

    context 'with existing records' do
      pending 'fires on before_save'
    end

    pending 'fires if year is blank'

    pending 'fires if month is blank'

    pending 'doesn\'t fire if year and month are both present'

    pending 'updates the record with the year and month from the date'
  end

  describe '#find_plan' do
    context 'on new records' do
      let(:report) { build :report_village }

      it 'fires on after_save' do
        expect(report.new_record?).to eq true
        expect(report).to receive(:find_plan).exactly(1).times

        report.save
      end
    end

    context 'on persistent records' do
      let(:report) { create :report_village }

      it 'fires on after_save' do
        report.impact = 25

        expect(report.persisted?).to eq true
        expect(report).to receive(:find_plan).exactly(1).times

        report.save
      end
    end

    context 'when a matching plan is found' do
      let(:new_report) { build :report_village }
      let(:existing_report) { create :report_village }

      it 'sets the plan_id' do
        new_plan = FactoryBot.create(:plan_village, contract: new_report.contract, technology: new_report.technology, planable: new_report.reportable)
        existing_plan = FactoryBot.create(:plan_village, contract: existing_report.contract, technology: existing_report.technology, planable: existing_report.reportable)

        expect { new_report.send(:find_plan) }.to change { new_report.plan_id }.from(nil).to(new_plan.id)
        expect { existing_report.send(:find_plan) }.to change { existing_report.plan_id }.from(nil).to(existing_plan.id)
      end
    end

    context 'when no matching plan is found' do
      let(:plan) { create :plan_village }
      let(:new_report) { build :report_village }
      let(:existing_report) { create :report_village }

      it 'does not set the plan_id' do
        expect { new_report.send(:find_plan) }.not_to change { new_report.plan_id }
        expect { existing_report.send(:find_plan) }.not_to change { existing_report.plan_id }
      end
    end
  end
end
