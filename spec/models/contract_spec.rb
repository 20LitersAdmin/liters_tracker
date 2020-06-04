# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contract, type: :model do
  let(:contract) { build :contract }

  context 'has validations on' do
    let(:no_start_date) { build :contract, start_date: nil }
    let(:no_end_date) { build :contract, end_date: nil }

    it 'start_date' do
      no_start_date.valid?

      expect(no_start_date.errors[:start_date]).to match_array("can't be blank")

      no_start_date.start_date = Date.today
      no_start_date.valid?

      expect(no_start_date.errors.any?).to eq false
    end

    it 'end_date' do
      no_end_date.valid?

      expect(no_end_date.errors[:end_date]).to match_array("can't be blank")

      no_end_date.end_date = Date.today
      no_end_date.valid?

      expect(no_end_date.errors.any?).to eq false
    end
  end

  context "has a 'current' scope which" do
    it 'returns the contract where the end_date is greater than today, with the newest start_date' do
      out_of_scope = FactoryBot.create :contract, start_date: Date.today - 10.years, end_date: Date.today - 8.years
      in_scope_but_old = FactoryBot.create :contract, start_date: Date.today - 2.years, end_date: Date.today + 2.years
      intended_result = FactoryBot.create :contract, start_date: Date.today - 1.year, end_date: Date.today + 2.years

      expect(Contract.current).to eq intended_result
      expect(Contract.current).not_to eq out_of_scope
      expect(Contract.current).not_to eq in_scope_but_old
    end
  end

  context "has a 'between' scope which" do
    it 'returns all contracts that fall within given dates at any point' do
      from = Date.today - 1.year
      to = Date.today
      too_old = FactoryBot.create :contract, start_date: Date.today - 3.years, end_date: Date.today - 2.years
      already_ended = FactoryBot.create :contract, start_date: Date.today - 2.years, end_date: Date.today - 6.months
      just_started = FactoryBot.create :contract, start_date: Date.today - 3.months, end_date: Date.today + 2.years
      within_range = FactoryBot.create :contract, start_date: Date.today - 8.months, end_date: Date.today - 1.month
      in_the_future = FactoryBot.create :contract, start_date: Date.today + 1.year, end_date: Date.today + 3.years

      expect(Contract.between(from, to)).to include already_ended
      expect(Contract.between(from, to)).to include just_started
      expect(Contract.between(from, to)).to include within_range

      expect(Contract.between(from, to)).not_to include too_old
      expect(Contract.between(from, to)).not_to include in_the_future
    end
  end

  describe 'name' do
    it 'returns a string containing the ID and dates' do
      contract.save

      expect(contract.name).to include("#{contract.id}:")
      expect(contract.name).to include(contract.start_date.strftime('%m/%Y'))
      expect(contract.name).to include(contract.end_date.strftime('%m/%Y'))
    end
  end

  describe 'url_params' do
    it 'returns a string formatted as a URL search parameter with the dates' do
      contract.save

      expect(contract.url_params).to include('?from=')
      expect(contract.url_params).to include('&to=')
      expect(contract.url_params).to include(contract.start_date.strftime('%Y-%m-%d'))
      expect(contract.url_params).to include(contract.end_date.strftime('%Y-%m-%d'))
    end
  end

  private

  describe '#find_reports' do
    before :each do
      contract.save

      3.times do
        FactoryBot.create(:report_village, date: contract.start_date + 10.days)
      end

      3.times do
        FactoryBot.create(:report_village, date: contract.start_date - 10.days)
      end

      # Saving the reports triggers Report#set_contract_from_date
      # So it must be manually cleared for this edge case.
      Report.update_all(contract_id: nil)
    end

    it 'finds all reports without a contract_id that fall within the contract period' do
      expect(contract.send(:find_reports)).to eq 3
    end

    fit 'updates all matching reports' do
      expect(Report.all.pluck(:contract_id).uniq).to eq [nil]

      contract.send(:find_reports)

      expect(Report.all.pluck(:contract_id).uniq).to eq [nil, contract.id]
      expect(Report.where(contract_id: contract.id).size).to eq 3
    end
  end
end
