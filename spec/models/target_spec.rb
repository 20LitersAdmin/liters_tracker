# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Target, type: :model do
  let(:target) { build :target }

  context 'has validations on' do
    let(:no_contract) { build :target, contract: nil }
    let(:bad_contract) { build :target, contract_id: 999 }
    let(:no_technology) { build :target, technology: nil }
    let(:bad_technology) { build :target, technology_id: 999 }
    let(:no_goal) { build :target, goal: nil }

    it 'contract' do
      no_contract.valid?
      expect(no_contract.errors[:contract_id]).to match_array("can't be blank")

      bad_contract.valid?
      expect(bad_contract.errors[:contract]).to match_array('must exist')
    end

    it 'technology' do
      no_technology.valid?
      expect(no_technology.errors[:technology_id]).to match_array("can't be blank")

      bad_technology.valid?
      expect(bad_technology.errors[:technology]).to match_array('must exist')
    end

    it 'goal' do
      no_goal.valid?
      expect(no_goal.errors[:goal]).to match_array("can't be blank")
    end
  end

  describe '#date' do
    it 'returns the end date of the parent contract' do
      target.save
      expect(target.date).to eq target.contract.end_date
    end
  end
end
