# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plan, type: :model do
  let(:plan) { build :plan_village }

  describe 'has validations on' do
    let(:no_contract) { build :plan_village, contract: nil }
    let(:no_technology) { build :plan_village, technology: nil }
    let(:no_goal) { build :plan_village, goal: nil }
    let(:no_planable) { build :plan_village, planable_type: nil, planable_id: nil }

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

    it 'goal' do
      no_goal.valid?
      expect(no_goal.errors[:goal]).to match_array("can't be blank")
    end

    it 'planable' do
      no_planable.valid?

      expect(no_planable.errors[:planable_id]).to match_array("can't be blank")
      expect(no_planable.errors[:planable_type]).to match_array("can't be blank")
    end
  end

  describe 'has scopes for dates' do
    let(:oldest_contract) { create :contract, start_date: Date.today - 6.years, end_date: Date.today - 5.years }
    let(:oldest_plan) { create :plan_village, contract: oldest_contract }
    let(:old_contract) { create :contract, start_date: Date.today - 4.years, end_date: Date.today - 3.years }
    let(:old_plan) { create :plan_village, contract: old_contract }
    let(:current_contract) { create :contract, start_date: Date.today - 1.year, end_date: Date.today + 1.year }
    let(:current_plan) { create :plan_village, contract: current_contract }
    let(:future_contract) { create :contract, start_date: Date.today + 2.years, end_date: Date.today + 3.years }
    let(:future_plan) { create :plan_village, contract: future_contract }

    it '.between returns all records that fall within given dates at any point' do
      expect(Plan.between(Date.today - 5.years, Date.today - 4.years)).to include(oldest_plan)
      expect(Plan.between(Date.today - 5.years, Date.today - 4.years)).to include(old_plan)
      expect(Plan.between(Date.today - 5.years, Date.today - 4.years)).not_to include(current_plan)
      expect(Plan.between(Date.today - 5.years, Date.today - 4.years)).not_to include(future_plan)

      expect(Plan.between(Date.today - 2.years, Date.today + 2.years)).not_to include(oldest_plan)
      expect(Plan.between(Date.today - 2.years, Date.today + 2.years)).not_to include(old_plan)
      expect(Plan.between(Date.today - 2.years, Date.today + 2.years)).to include(current_plan)
      expect(Plan.between(Date.today - 2.years, Date.today + 2.years)).to include(future_plan)
    end

    it '.current returns all records linked to the current contract' do
      3.times do
        FactoryBot.create(:plan_village, contract: current_contract)
      end
      current_plan

      expect(Plan.current.size).to eq 4
    end

    it '.nearest_to_date returns all records where the parent contract\'s end date is >= the given date' do
      oldest_contract
      oldest_plan
      old_contract
      old_plan
      current_contract
      current_plan
      future_contract
      future_plan

      expect(Plan.nearest_to_date(Date.today)).not_to include(oldest_plan)
      expect(Plan.nearest_to_date(Date.today)).not_to include(old_plan)

      expect(Plan.nearest_to_date(Date.today)).to include(current_plan)
      expect(Plan.nearest_to_date(Date.today)).to include(future_plan)
    end
  end

  describe 'has scopes for types' do
    let(:facility) { create :plan_facility }
    let(:village) { create :plan_village }
    let(:cell) { create :plan_cell }
    let(:sector) { create :plan_sector }
    let(:district) { create :plan_district }

    it 'only_districts' do
      expect(Plan.only_districts).to include(district)

      expect(Plan.only_districts).not_to include(sector)
      expect(Plan.only_districts).not_to include(cell)
      expect(Plan.only_districts).not_to include(village)
      expect(Plan.only_districts).not_to include(facility)
    end

    it 'only_sectors' do
      expect(Plan.only_sectors).to include(sector)

      expect(Plan.only_sectors).not_to include(facility)
      expect(Plan.only_sectors).not_to include(village)
      expect(Plan.only_sectors).not_to include(cell)
      expect(Plan.only_sectors).not_to include(district)
    end

    it 'only_cells' do
      expect(Plan.only_cells).to include(cell)

      expect(Plan.only_cells).not_to include(facility)
      expect(Plan.only_cells).not_to include(village)
      expect(Plan.only_cells).not_to include(sector)
      expect(Plan.only_cells).not_to include(district)
    end

    it 'only_villages' do
      expect(Plan.only_villages).to include(village)

      expect(Plan.only_villages).not_to include(facility)
      expect(Plan.only_villages).not_to include(cell)
      expect(Plan.only_villages).not_to include(sector)
      expect(Plan.only_villages).not_to include(district)
    end

    it 'only_facilities' do
      expect(Plan.only_facilities).to include(facility)

      expect(Plan.only_facilities).not_to include(village)
      expect(Plan.only_facilities).not_to include(cell)
      expect(Plan.only_facilities).not_to include(sector)
      expect(Plan.only_facilities).not_to include(district)
    end
  end

  describe 'has scopes that joins reports' do
    let(:plan1) { create :plan_village, goal: 5 }
    let(:plan2) { create :plan_village, goal: 20 }
    let(:plan3) { create :plan_village, goal: 10 }

    let(:rep1) do
      create :report_village, contract: plan1.contract, technology: plan1.technology,
                              reportable_id: plan1.planable_id, reportable_type: plan1.planable_type, distributed: 3
    end

    let(:rep2) do
      create :report_village, contract: plan1.contract, technology: plan1.technology,
                              reportable_id: plan1.planable_id, reportable_type: plan1.planable_type, distributed: 2
    end

    let(:rep3) do
      create :report_village, contract: plan2.contract, technology: plan2.technology,
                              reportable_id: plan2.planable_id, reportable_type: plan2.planable_type, distributed: 10
    end

    describe '.without_reports' do
      it 'returns plans with no associated reports' do
        plan1
        plan2
        plan3

        rep1
        rep2
        rep3

        expect(Plan.all.size).to eq 3
        expect(Plan.without_reports.size).to eq 1
        expect(Plan.without_reports).to include plan3
        expect(Plan.without_reports).not_to include plan1
        expect(Plan.without_reports).not_to include plan2
      end
    end

    describe '.with_reports_incomplete' do
      it 'returns plans where the associated reports don\'t complete the goal' do
        plan1
        plan2
        plan3

        rep1
        rep2
        rep3

        expect(Plan.all.size).to eq 3

        expect(Plan.with_reports_incomplete.length).to eq 1

        expect(Plan.with_reports_incomplete).to include plan2
        expect(Plan.with_reports_incomplete).not_to include plan1
        expect(Plan.with_reports_incomplete).not_to include plan3
      end
    end

    describe 'self.incomplete' do
      it 'returns plans with no associated reports' do
        plan1
        plan2
        plan3

        rep1
        rep2
        rep3

        expect(Plan.incomplete).to include plan3
        expect(Plan.incomplete).to include plan2
        expect(Plan.incomplete).not_to include plan1
      end
    end
  end

  describe '#picture' do
    let(:plan_facility) { create :plan_facility }
    let(:plan_village) { create :plan_village }
    let(:plan_sector) { create :plan_sector }

    it "returns 'plan_facility.jpg when planable_type == 'Facility" do
      expect(plan_facility.picture).to eq 'plan_facility.jpg'
    end

    it "returns 'plan_village.jpg when planable_type != 'Facility" do
      expect(plan_village.picture).to eq 'plan_village.jpg'
      expect(plan_sector.picture).to eq 'plan_village.jpg'
    end
  end

  describe '#title' do
    let(:plan) { create :plan_village }

    it 'includes the goal' do
      expect(plan.title).to include(plan.goal.to_s)
    end

    it 'includes the technology name' do
      expect(plan.title).to include(plan.technology.name)
    end

    it 'includes the people_goal' do
      expect(plan.title).to include("for #{plan.people_goal} people")
    end

    it 'inlcudes the date' do
      plan.date = Date.today

      expect(plan.title).to include("by #{plan.date.strftime('%m/%d/%Y')}")
    end
  end

  describe '#complete?' do
    let(:plan1) { create :plan_village, goal: 5 }
    let(:plan2) { create :plan_village, goal: 20 }
    let(:plan3) { create :plan_village, goal: 10 }

    let(:rep1) do
      create :report_village, contract: plan1.contract, technology: plan1.technology,
                              reportable_id: plan1.planable_id, reportable_type: plan1.planable_type, distributed: 3
    end

    let(:rep2) do
      create :report_village, contract: plan1.contract, technology: plan1.technology,
                              reportable_id: plan1.planable_id, reportable_type: plan1.planable_type, distributed: 3
    end

    let(:rep3) do
      create :report_village, contract: plan2.contract, technology: plan2.technology,
                              reportable_id: plan2.planable_id, reportable_type: plan2.planable_type, distributed: 10
    end

    it 'returns true if the sum of reports.distributed is greater than the goal' do
      plan1
      plan2
      plan3

      rep1
      rep2
      rep3

      expect(plan1.complete?).to eq true
    end

    it 'returns false if the sum of reports.distributed is less than the goal' do
      plan1
      plan2
      plan3

      rep1
      rep2
      rep3

      expect(plan2.complete?).to eq false
      expect(plan3.complete?).to eq false
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
      let(:related_plan1) { create :plan_facility, contract: contract, planable: related_facility1 }
      let(:related_plan2) { create :plan_facility, contract: contract, planable: related_facility2 }
      let(:related_plan3) { create :plan_facility, contract: contract, planable: related_facility3 }
      let(:unrelated_plan1) { create :plan_district, contract: contract }
      let(:unrelated_plan2) { create :plan_facility, planable: related_facility1 }
      let(:unrelated_plan3) { create :plan_facility, planable: unrelated_facility1 }

      it 'returns a collection of facilities from a collection of plans' do
        related_plan1
        related_plan2
        related_plan3
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3

        collection = contract.plans

        expect(collection.related_facilities).to include related_facility1
        expect(collection.related_facilities).to include related_facility2
        expect(collection.related_facilities).to include related_facility3

        expect(collection.related_facilities).not_to include unrelated_facility1
        expect(collection.related_facilities).not_to include unrelated_facility2
        expect(collection.related_facilities).not_to include unrelated_facility3
      end

      it 'returns an empty ActiveRecord::Relation if none are found' do
        related_plan1.delete
        related_plan2.delete
        related_plan3.delete
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3

        collection = contract.plans

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
      let(:related_plan1) { create :plan_facility, contract: contract, planable: related_facility1 }
      let(:related_plan2) { create :plan_facility, contract: contract, planable: related_facility2 }
      let(:related_plan3) { create :plan_facility, contract: contract, planable: related_facility3 }
      let(:related_plan4) { create :plan_village, contract: contract, planable: related_village1 }
      let(:related_plan5) { create :plan_village, contract: contract, planable: related_village2 }
      let(:related_plan6) { create :plan_village, contract: contract, planable: related_village3 }
      let(:unrelated_plan1) { create :plan_district, contract: contract }
      let(:unrelated_plan2) { create :plan_facility, planable: related_facility1 }
      let(:unrelated_plan3) { create :plan_village, planable: unrelated_village1 }

      it 'returns a collection of villages from a collection of plans' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        related_plan6
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3

        collection = contract.plans

        expect(collection.related_villages).to include related_village
        expect(collection.related_villages).to include related_village1
        expect(collection.related_villages).to include related_village2
        expect(collection.related_villages).to include related_village3

        expect(collection.related_villages).not_to include unrelated_village1
        expect(collection.related_villages).not_to include unrelated_village2
        expect(collection.related_villages).not_to include unrelated_village3
      end

      it 'returns an empty ActiveRecord::Relation if none are found' do
        related_plan1.delete
        related_plan2.delete
        related_plan3.delete
        related_plan4.delete
        related_plan5.delete
        related_plan6.delete
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3

        collection = contract.plans

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

      let(:related_plan1) { create :plan_facility, contract: contract, planable: related_facility }
      let(:related_plan2) { create :plan_village, contract: contract, planable: related_village }
      let(:related_plan3) { create :plan_cell, contract: contract, planable: related_cell }
      let(:related_plan4) { create :plan_cell, contract: contract, planable: related_cell1 }
      let(:related_plan5) { create :plan_cell, contract: contract, planable: related_cell2 }
      let(:unrelated_plan1) { create :plan_district, contract: contract }
      let(:unrelated_plan2) { create :plan_facility, planable: related_facility }
      let(:unrelated_plan3) { create :plan_cell, planable: unrelated_cell1 }

      it 'returns a collection of cells from a collection of plans' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3

        collection = contract.plans

        expect(collection.related_cells).to include related_cell
        expect(collection.related_cells).to include related_cell1
        expect(collection.related_cells).to include related_cell2

        expect(collection.related_cells).not_to include unrelated_cell1
        expect(collection.related_cells).not_to include unrelated_cell2
      end

      it 'returns an empty ActiveRecord::Relation if none are found' do
        related_plan1.delete
        related_plan2.delete
        related_plan3.delete
        related_plan4.delete
        related_plan5.delete
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3

        collection = contract.plans

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

      let(:related_plan1) { create :plan_facility, contract: contract, planable: related_facility }
      let(:related_plan2) { create :plan_village, contract: contract, planable: related_village }
      let(:related_plan3) { create :plan_cell, contract: contract, planable: related_cell }
      let(:related_plan4) { create :plan_sector, contract: contract, planable: related_sector }
      let(:related_plan5) { create :plan_sector, contract: contract, planable: related_sector1 }
      let(:related_plan6) { create :plan_sector, contract: contract, planable: related_sector2 }
      let(:unrelated_plan1) { create :plan_district, contract: contract }
      let(:unrelated_plan2) { create :plan_facility, planable: related_facility }
      let(:unrelated_plan3) { create :plan_sector, planable: unrelated_sector1 }

      it 'returns a collection of sectors from a collection of plans' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        related_plan6
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3

        collection = contract.plans

        expect(collection.related_sectors).to include related_sector
        expect(collection.related_sectors).to include related_sector1
        expect(collection.related_sectors).to include related_sector2

        expect(collection.related_sectors).not_to include unrelated_sector1
        expect(collection.related_sectors).not_to include unrelated_sector2
      end

      it 'returns an empty ActiveRecord::Relation if none are found' do
        related_plan1.delete
        related_plan2.delete
        related_plan3.delete
        related_plan4.delete
        related_plan5.delete
        related_plan6.delete
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3

        collection = contract.plans

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

      let(:related_plan1) { create :plan_facility, contract: contract, planable: related_facility }
      let(:related_plan2) { create :plan_village, contract: contract, planable: related_village }
      let(:related_plan3) { create :plan_cell, contract: contract, planable: related_cell }
      let(:related_plan4) { create :plan_sector, contract: contract, planable: related_sector }
      let(:related_plan5) { create :plan_district, contract: contract, planable: related_district }
      let(:related_plan6) { create :plan_district, contract: contract, planable: related_district1 }
      let(:related_plan7) { create :plan_district, contract: contract, planable: related_district2 }
      let(:unrelated_plan1) { create :plan_facility }
      let(:unrelated_plan2) { create :plan_facility, planable: related_facility }
      let(:unrelated_plan3) { create :plan_district, planable: unrelated_district1 }

      it 'returns a collection of districts from a collection of plans' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        related_plan6
        related_plan7
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3

        collection = contract.plans

        expect(collection.related_districts).to include related_district
        expect(collection.related_districts).to include related_district1
        expect(collection.related_districts).to include related_district2

        expect(collection.related_districts).not_to include unrelated_district1
        expect(collection.related_districts).not_to include unrelated_district2
      end

      it 'returns an empty ActiveRecord::Relation if none are found' do
        related_plan1.delete
        related_plan2.delete
        related_plan3.delete
        related_plan4.delete
        related_plan5.delete
        related_plan6.delete
        related_plan7.delete
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3

        collection = contract.plans

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
      let(:related_plan1) { create :plan_facility, contract: contract, planable: related_facility1 }
      let(:related_plan2) { create :plan_facility, contract: contract, planable: related_facility2 }
      let(:related_plan3) { create :plan_facility, contract: contract, planable: related_facility3 }
      let(:unrelated_plan1) { create :plan_district, contract: contract }
      let(:unrelated_plan2) { create :plan_facility, planable: related_facility1 }
      let(:unrelated_plan3) { create :plan_facility, planable: unrelated_facility1 }

      it 'returns the village_ids of the results of #related_facilites' do
        related_plan1
        related_plan2
        related_plan3
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3
        collection = contract.plans
        expect(collection.send(:ary_of_village_ids_from_facilities).empty?).to eq false
        expect(collection.send(:ary_of_village_ids_from_facilities)).to eq collection.related_facilities.pluck(:village_id)
      end

      it 'returns an array' do
        related_plan1
        related_plan2
        related_plan3
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3
        collection = contract.plans
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
      let(:related_plan1) { create :plan_facility, contract: contract, planable: related_facility1 }
      let(:related_plan2) { create :plan_facility, contract: contract, planable: related_facility2 }
      let(:related_plan3) { create :plan_facility, contract: contract, planable: related_facility3 }
      let(:related_plan4) { create :plan_village, contract: contract, planable: related_village1 }
      let(:related_plan5) { create :plan_village, contract: contract, planable: related_village2 }
      let(:related_plan6) { create :plan_village, contract: contract, planable: related_village3 }
      let(:unrelated_plan1) { create :plan_district, contract: contract }
      let(:unrelated_plan2) { create :plan_facility, planable: related_facility1 }
      let(:unrelated_plan3) { create :plan_village, planable: unrelated_village1 }

      it 'returns the cell_ids of the results of #related_villages' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        related_plan6
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3
        collection = contract.plans
        expect(collection.send(:ary_of_cell_ids_from_villages).empty?).to eq false
        expect(collection.send(:ary_of_cell_ids_from_villages)).to eq collection.related_villages.pluck(:cell_id)
      end

      it 'returns an array' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        related_plan6
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3
        collection = contract.plans
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

      let(:related_plan1) { create :plan_facility, contract: contract, planable: related_facility }
      let(:related_plan2) { create :plan_village, contract: contract, planable: related_village }
      let(:related_plan3) { create :plan_cell, contract: contract, planable: related_cell }
      let(:related_plan4) { create :plan_cell, contract: contract, planable: related_cell1 }
      let(:related_plan5) { create :plan_cell, contract: contract, planable: related_cell2 }
      let(:unrelated_plan1) { create :plan_district, contract: contract }
      let(:unrelated_plan2) { create :plan_facility, planable: related_facility }
      let(:unrelated_plan3) { create :plan_cell, planable: unrelated_cell1 }

      it 'returns the sector_ids of the results of #related_cells' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3
        collection = contract.plans
        expect(collection.send(:ary_of_sector_ids_from_cells).empty?).to eq false
        expect(collection.send(:ary_of_sector_ids_from_cells)).to eq collection.related_cells.pluck(:sector_id)
      end

      it 'returns an array' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3
        collection = contract.plans
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

      let(:related_plan1) { create :plan_facility, contract: contract, planable: related_facility }
      let(:related_plan2) { create :plan_village, contract: contract, planable: related_village }
      let(:related_plan3) { create :plan_cell, contract: contract, planable: related_cell }
      let(:related_plan4) { create :plan_sector, contract: contract, planable: related_sector }
      let(:related_plan5) { create :plan_sector, contract: contract, planable: related_sector1 }
      let(:related_plan6) { create :plan_sector, contract: contract, planable: related_sector2 }
      let(:unrelated_plan1) { create :plan_district, contract: contract }
      let(:unrelated_plan2) { create :plan_facility, planable: related_facility }
      let(:unrelated_plan3) { create :plan_sector, planable: unrelated_sector1 }

      it 'returns the district_ids of the results of #related_sectors' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        related_plan6
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3
        collection = contract.plans
        expect(collection.send(:ary_of_district_ids_from_sectors).empty?).to eq false
        expect(collection.send(:ary_of_district_ids_from_sectors)).to eq collection.related_sectors.pluck(:district_id)
      end

      it 'returns an array' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        related_plan6
        unrelated_plan1
        unrelated_plan2
        unrelated_plan3
        collection = contract.plans
        expect(collection.send(:ary_of_district_ids_from_sectors).is_a?(Array)).to eq true
      end
    end
  end

  private

  describe '#find_reports' do
    before :each do
      plan.save
      contract = plan.contract
      technology = plan.technology
      geography = plan.planable

      3.times do
        FactoryBot.create(:report_village, date: contract.start_date + 2.months,
                                           technology: technology,
                                           reportable: geography)
      end

      3.times do
        FactoryBot.create(:report_facility, date: contract.end_date + 2.months)
      end

      # Saving the reports triggers Report#set_contract_from_date
      # which then allows for Report#set_plan to fire
      # So it must be manually cleared for this edge case.
      Report.update_all(plan_id: nil)
    end

    it 'finds all reports where everything matches except the plan_id' do
      expect(plan.send(:find_reports)).to eq 3
    end

    it 'sets the plan_id for all matching plans' do
      expect(Report.all.pluck(:plan_id).uniq).to eq [nil]

      plan.send(:find_reports)

      expect(Report.all.pluck(:plan_id).uniq).to include(nil, plan.id)
      expect(Report.where(plan_id: plan.id).size).to eq 3
    end
  end
end
