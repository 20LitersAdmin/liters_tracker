# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Target form', type: :system do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)
    @contract = FactoryBot.create(:contract)
    @technology = FactoryBot.create(:technology_community)
  end

  context '#new' do
    it 'is accessed from /contracts/:id' do
      visit contract_path(@contract)

      expect(page).to have_link 'Add Target'

      click_link 'Add Target'

      expect(page).to have_content 'New Target'
    end

    it 'has the necessary fields' do
      visit new_contract_target_path(@contract)

      expect(page).to have_content 'New Target'

      expect(page).to have_field 'target_technology_id'
      expect(page).to have_field 'target_goal'
      expect(page).to have_field 'target_people_goal'
      expect(page).to have_button 'Create Target'
    end

    it 'creates a target' do
      new_target = FactoryBot.build(:target, contract: @contract)
      visit new_contract_target_path(@contract)

      expect(page).to have_content 'New Target'

      first_count = Target.all.size

      select @technology.name, from: 'target_technology_id'
      fill_in 'target_goal', with: new_target.goal
      fill_in 'target_people_goal', with: new_target.people_goal

      click_submit

      expect(page).to have_content 'Target created.'

      second_count = Target.all.size

      expect(second_count).to eq first_count + 1
    end
  end

  context '#edit' do
    before :each do
      @target = FactoryBot.create(:target, technology: @technology, contract: @contract)
    end

    it 'is linked from /contracts/:id' do
      visit contract_path(@contract)

      expect(page).to have_content "Contract ##{@contract.name}"
      expect(page).to have_css 'table#targets_table'
      expect(page).to have_link 'Edit', href: edit_contract_target_path(@contract, @target)
    end

    it 'edits the target' do
      visit edit_contract_target_path(@contract, @target)

      expect(page).to have_content 'Edit Target'

      fill_in 'target_goal', with: 10

      click_submit

      expect(page).to have_content 'Target updated.'
      expect(@target.reload.goal).to eq 10
    end
  end
end
