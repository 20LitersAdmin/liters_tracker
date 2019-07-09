# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plan, type: :model do
  let(:plan) { build :plan_village }

  context 'has validations on' do
    let(:no_contract) { build :plan_village, contract: nil }
    let(:no_technology) { build :plan_village, technology: nil }
    let(:no_model_gid) { build :plan_village, model_gid: nil }
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

    it 'model_gid' do
      no_model_gid.valid?
      expect(no_model_gid.errors[:model_gid]).to match_array("can't be blank")
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
    context '#related_to' do
    end

    context '#related_to_facility' do
    end

    context '#related_to_village' do
    end

    context '#related_to_cell' do
    end

    context '#related_to_sector' do
    end

    context '#related_to_district' do
    end

    context '#related_facilities' do
    end
  end

  context 'geography collection methods' do
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

  context '.date' do
    it 'returns the end_date of the associated contract' do
      plan.save
      expect(plan.date).to eq plan.contract.end_date
    end
  end

  context '.model' do
    it 'returns the associated geography' do
      plan.model_gid = plan.planable.to_global_id.to_s
      plan.save
      expect(plan.model).to eq plan.planable
    end
  end
end
