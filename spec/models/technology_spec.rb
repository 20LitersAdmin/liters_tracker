# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Technology, type: :model do
  let(:user) { create :user_admin }

  describe '#lifetime_impact' do
    let!(:technology) { create :technology }
    let(:contract)    { create :contract }
    let!(:report)     { create :report_facility, user: user, contract: contract, technology: technology, people: 10 }

    it do
      expect(technology.reload.lifetime_impact).to eq(10)
    end

    context 'has no reports' do
      before { technology.reports.last.destroy }

      it do
        expect(technology.reload.lifetime_impact).to eq(0)
      end
    end

    context 'has reports with nil people' do
      let!(:report_1) { create :report_facility, user: user, contract: contract, technology: technology, people: 5 }
      let!(:report_2) { create :report_facility, user: user, contract: contract, technology: technology, people: nil }
      let!(:report_3) { create :report_facility, user: user, contract: contract, technology: technology, people: 13 }

      it do
        expect(technology.reload.lifetime_impact).to eq(28)
      end
    end
  end

  let(:technology) { build :technology_family }

  context 'has validations on' do
    let(:no_name) { build :technology_family, name: nil }
    let(:no_short_name) { build :technology_family, short_name: nil }
    let(:no_default_impact) { build :technology_family, default_impact: nil }
    let(:no_agreement_required) { build :technology_family, agreement_required: nil }
    let(:no_scale) { build :technology_family, scale: nil }
    let(:bad_scale) { build :technology_family, scale: 'small' }

    it 'name' do
      no_name.valid?
      expect(no_name.errors[:name]).to match_array("can't be blank")

      no_name.name = 'has a name'
      no_name.valid?
      expect(no_name.errors.any?).to eq false
    end

    it 'short_name' do
      no_short_name.valid?
      expect(no_short_name.errors[:short_name]).to match_array("can't be blank")

      no_short_name.short_name = 'has a name'
      no_short_name.valid?
      expect(no_short_name.errors.any?).to eq false
    end

    it 'default_impact' do
      no_default_impact.valid?
      expect(no_default_impact.errors[:default_impact]).to match_array("can't be blank")

      no_default_impact.default_impact = 1
      no_default_impact.valid?
      expect(no_default_impact.errors.any?).to eq false
    end

    it 'agreement_required' do
      no_agreement_required.valid?
      expect(no_agreement_required.errors[:agreement_required][0]).to include('is not included in the list')

      no_agreement_required.agreement_required = true
      no_agreement_required.valid?
      expect(no_agreement_required.errors.any?).to eq false


      no_agreement_required.agreement_required = false
      no_agreement_required.valid?
      expect(no_agreement_required.errors.any?).to eq false
    end

    it 'scale' do
      no_scale.valid?
      expect(no_scale.errors[:scale][0]).to include('Must be one of these:')

      bad_scale.valid?
      expect(bad_scale.errors[:scale][0]).to include('Must be one of these:')
    end
  end

  context '.report_worthy' do
    let(:report_worthy) { create :technology_family, report_worthy: true }
    let(:not_report_worthy) { create :technology_family, report_worthy: false }

    it 'returns only Technology where report_worthy is true' do
      expect(Technology.report_worthy).to include report_worthy
      expect(Technology.report_worthy).not_to include not_report_worthy
    end
  end

  context '#default_household_impact' do
    it 'returns an integer that divides the default_impact by the HOUSEHOLD_SIZE constant' do
      # HOUSEHOLD_SIZE = 5
      technology.update(default_impact: 10)

      expect(technology.default_household_impact).to eq 2
    end
  end
end
