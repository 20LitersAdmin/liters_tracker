# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract form', type: :system do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)
  end

  context '#new' do
    it 'is accessed from /contracts' do
      visit contracts_path

      expect(page).to have_link 'New Contract'
    end

    it 'has the necessary fields' do
      visit new_contract_path

      expect(page).to have_content 'New contract'

      expect(page).to have_field 'contract_start_date'
      expect(page).to have_field 'contract_end_date'
      expect(page).to have_field 'contract_budget'
      expect(page).to have_field 'contract_household_goal'
      expect(page).to have_field 'contract_people_goal'

      expect(page).to have_button 'Create Contract'
    end

    it 'creates the contract' do
      new_contract = FactoryBot.build(:contract)
      visit new_contract_path

      expect(page).to have_content 'New contract'

      fill_in 'contract_start_date', with: new_contract.start_date
      fill_in 'contract_end_date', with: new_contract.end_date
      fill_in 'contract_budget', with: new_contract.budget
      fill_in 'contract_household_goal', with: new_contract.household_goal
      fill_in 'contract_people_goal', with: new_contract.people_goal

      click_submit

      expect(page).to have_content "Contract ##{new_contract.name}"
    end
  end

  context '#edit' do
    before :each do
      @contract = FactoryBot.create(:contract)
    end

    it 'is linked from /contracts/:id' do
      visit contract_path(@contract)

      expect(page).to have_content "Contract ##{@contract.name}"
      expect(page).to have_link 'Edit', href: edit_contract_path(@contract)
    end

    it 'edits a contract' do
      visit edit_contract_path(@contract)

      expect(page).to have_content 'Edit contract'

      fill_in 'contract_budget', with: 10

      click_submit

      expect(page).to have_content "Contract ##{@contract.name}"
      expect(page).to have_content '$10'
    end
  end
end
