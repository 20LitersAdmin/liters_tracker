# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plan, type: :model do
  let(:plan) { build :plan_village }

  context 'has validations on' do
    let(:no_contract) { build :plan_village, contract: nil }
    let(:no_technology) { build :plan_village, technology: nil }
    let(:no_goal) { build :plan_village, goal: nil }

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
  end

  context 'has scopes for dates' do
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

  context 'has scopes for types' do
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
      let(:related_plan1) { create :plan_village, planable: village }
      let(:related_plan2) { create :plan_village, planable: village }
      let(:unrelated_plan) { create :plan_village, planable: other_village }

      it 'returns a collection of plans directly related to the given geography' do
        related_plan1
        related_plan2
        collection = Plan.related_to(village)

        expect(collection).to include related_plan1
        expect(collection).to include related_plan2
        expect(collection).not_to include unrelated_plan
      end

      it 'returns an empty ActiveRecord collection if no records are found' do
        related_plan1.delete
        related_plan2.delete

        collection = Plan.related_to(village)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end
    end

    context '#related_to_facility' do
      let(:related_plan1) { create :plan_facility, planable: facility }
      let(:related_plan2) { create :plan_facility, planable: facility }
      let(:unrelated_plan) { create :plan_facility, planable: other_facility }

      it 'returns a collection of plans directly related to the given facility' do
        related_plan1
        related_plan2
        collection = Plan.related_to_facility(facility)

        expect(collection).to include related_plan1
        expect(collection).to include related_plan2
        expect(collection).not_to include unrelated_plan
      end

      it 'returns an empty ActiveRecord collection if no records are found' do
        unrelated_plan.delete

        collection = Plan.related_to_facility(other_facility)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end

      it 'returns an error if facility is not provided' do
        expect { Plan.related_to_facility(village) }.to raise_error RuntimeError
      end
    end

    context '#related_to_village' do
      let(:related_plan1) { create :plan_village, planable: village }
      let(:related_plan2) { create :plan_village, planable: village }
      let(:unrelated_plan) { create :plan_village, planable: other_village }
      let(:child_plan1) { create :plan_facility, planable: facility }
      let(:child_plan2) { create :plan_facility, planable: facility }
      let(:unrelated_plan2) { create :plan_facility, planable: other_facility }

      it 'returns a collection of plans related to the given village and its children' do
        related_plan1
        related_plan2
        child_plan1
        child_plan2
        collection = Plan.related_to_village(village)

        expect(collection).to include related_plan1
        expect(collection).to include related_plan2
        expect(collection).to include child_plan1
        expect(collection).to include child_plan2
        expect(collection).not_to include unrelated_plan
        expect(collection).not_to include unrelated_plan2
      end

      it 'returns an empty ActiveRecord collection if no records are found' do
        unrelated_plan.delete

        collection = Plan.related_to_village(other_village)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end

      it 'returns an error if village is not provided' do
        expect { Plan.related_to_village(district) }.to raise_error RuntimeError
      end
    end

    context '#related_to_cell' do
      let(:related_plan1) { create :plan_village, planable: village }
      let(:related_plan2) { create :plan_village, planable: village }
      let(:related_plan3) { create :plan_facility, planable: facility }
      let(:related_plan4) { create :plan_facility, planable: facility }
      let(:related_plan5) { create :plan_cell, planable: cell }
      let(:unrelated_plan1) { create :plan_facility, planable: other_facility }
      let(:unrelated_plan2) { create :plan_village, planable: other_village }
      let(:unrelated_plan3) { create :plan_cell, planable: other_cell }

      it 'returns a collection of plans related to the given cell and its children' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        collection = Plan.related_to_cell(cell)

        expect(collection).to include related_plan1
        expect(collection).to include related_plan2
        expect(collection).to include related_plan3
        expect(collection).to include related_plan4
        expect(collection).to include related_plan5
        expect(collection).not_to include unrelated_plan1
        expect(collection).not_to include unrelated_plan2
        expect(collection).not_to include unrelated_plan3
      end

      it 'returns an empty ActiveRecord collection if no records are found' do
        unrelated_plan3.delete

        collection = Plan.related_to_cell(other_cell)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end

      it 'returns an error if cell is not provided' do
        expect { Plan.related_to_cell(district) }.to raise_error RuntimeError
      end
    end

    context '#related_to_sector' do
      let(:related_plan1) { create :plan_village, planable: village }
      let(:related_plan2) { create :plan_village, planable: village }
      let(:related_plan3) { create :plan_facility, planable: facility }
      let(:related_plan4) { create :plan_facility, planable: facility }
      let(:related_plan5) { create :plan_cell, planable: cell }
      let(:related_plan6) { create :plan_sector, planable: sector }
      let(:unrelated_plan1) { create :plan_facility, planable: other_facility }
      let(:unrelated_plan2) { create :plan_village, planable: other_village }
      let(:unrelated_plan3) { create :plan_cell, planable: other_cell }
      let(:unrelated_plan4) { create :plan_sector, planable: other_sector }

      it 'returns a collection of plans related to the given sector and its children' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        related_plan6
        collection = Plan.related_to_sector(sector)

        expect(collection).to include related_plan1
        expect(collection).to include related_plan2
        expect(collection).to include related_plan3
        expect(collection).to include related_plan4
        expect(collection).to include related_plan5
        expect(collection).to include related_plan6
        expect(collection).not_to include unrelated_plan1
        expect(collection).not_to include unrelated_plan2
        expect(collection).not_to include unrelated_plan3
        expect(collection).not_to include unrelated_plan4
      end

      it 'returns an empty ActiveRecord collection if no records are found' do
        unrelated_plan4.delete

        collection = Plan.related_to_sector(other_sector)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end

      it 'returns an error if sector is not provided' do
        expect { Plan.related_to_sector(district) }.to raise_error RuntimeError
      end
    end

    context '#related_to_district' do
      let(:related_plan1) { create :plan_village, planable: village }
      let(:related_plan2) { create :plan_facility, planable: facility }
      let(:related_plan3) { create :plan_cell, planable: cell }
      let(:related_plan4) { create :plan_sector, planable: sector }
      let(:related_plan5) { create :plan_district, planable: district }
      let(:unrelated_plan1) { create :plan_facility, planable: other_facility }
      let(:unrelated_plan2) { create :plan_village, planable: other_village }
      let(:unrelated_plan3) { create :plan_cell, planable: other_cell }
      let(:unrelated_plan4) { create :plan_sector, planable: other_sector }
      let(:unrelated_plan5) { create :plan_district, planable: other_district }

      it 'returns a collection of plans related to the given district and its children' do
        related_plan1
        related_plan2
        related_plan3
        related_plan4
        related_plan5
        collection = Plan.related_to_district(district)

        expect(collection).to include related_plan1
        expect(collection).to include related_plan2
        expect(collection).to include related_plan3
        expect(collection).to include related_plan4
        expect(collection).to include related_plan5
        expect(collection).not_to include unrelated_plan1
        expect(collection).not_to include unrelated_plan2
        expect(collection).not_to include unrelated_plan3
        expect(collection).not_to include unrelated_plan4
        expect(collection).not_to include unrelated_plan5
      end

      it 'returns an empty ActiveRecord collection if no records are found' do
        unrelated_plan5.delete

        collection = Plan.related_to_district(other_district)
        expect(collection.is_a?(ActiveRecord::Relation)).to eq true
        expect(collection.empty?).to eq true
      end

      it 'returns an error if district is not provided' do
        expect { Plan.related_to_district(facility) }.to raise_error RuntimeError
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
      let(:related_district) { create :district, name: 'related_district' }
      let(:related_district1) { create :district, name: 'related_district1' }
      let(:related_district2) { create :district, name: 'related_district2' }
      let(:related_sector) { create :sector, district: related_district }
      let(:related_cell) { create :cell, sector: related_sector }
      let(:related_village) { create :village, cell: related_cell }
      let(:related_facility) { create :facility, village: related_village }
      let(:unrelated_district1) { create :district, name: 'unrelated_district1' }
      let(:unrelated_district2) { create :district, name: 'unrelated_district2' }

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

  context '.date' do
    it 'returns the end_date of the associated contract' do
      plan.save
      expect(plan.date).to eq plan.contract.end_date
    end
  end
end
