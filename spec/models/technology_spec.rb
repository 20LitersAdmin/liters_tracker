# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Technology, type: :model do
  let(:user)        { create :user }
  let!(:technology) { create :technology }

  describe '#lifetime_impact' do
    let(:contract) { create :contract }
    let!(:report)  { create :report, user: user, contract: contract, technology: technology, people: 10 }

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
      let!(:report_1) { create :report, user: user, contract: contract, technology: technology, people: 5 }
      let!(:report_2) { create :report, user: user, contract: contract, technology: technology, people: nil }
      let!(:report_3) { create :report, user: user, contract: contract, technology: technology, people: 13 }

      it do
        expect(technology.reload.lifetime_impact).to eq(28)
      end
    end
  end
end
