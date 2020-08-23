# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Technology form', type: :system do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)
  end

  context '#new' do
    it 'is linked from /technologies' do
      visit technologies_path

      expect(page).to have_link 'New'
    end

    it 'has the necessary fields' do
      visit new_technology_path

      expect(page).to have_content 'New technology'

      expect(page).to have_field 'technology_name'
      expect(page).to have_field 'technology_short_name'
      expect(page).to have_field 'technology_description'
      expect(page).to have_field 'technology_default_impact'
      expect(page).to have_field 'technology_scale'
      expect(page).to have_field 'technology_image_name'
      expect(page).to have_field 'technology_agreement_required'
      expect(page).to have_field 'technology_is_engagement'
      expect(page).to have_field 'technology_report_worthy'
      expect(page).to have_field 'technology_dashboard_worthy'
      expect(page).to have_field 'technology_direct_cost'
      expect(page).to have_field 'technology_indirect_cost'
      expect(page).to have_field 'technology_us_cost'
      expect(page).to have_field 'technology_local_cost'
      expect(page).to have_button 'Create Technology'
    end

    it 'creates a technology' do
      new_technology = FactoryBot.build(:technology)

      visit new_technology_path

      expect(page).to have_content 'New technology'

      fill_in 'technology_name', with: new_technology.name
      fill_in 'technology_short_name', with: new_technology.short_name
      fill_in 'technology_default_impact', with: new_technology.default_impact
      select new_technology.scale, from: 'technology_scale'
      check 'Include in reports'
      check 'Include on dashboard'
      fill_in 'technology_direct_cost', with: new_technology.direct_cost
      fill_in 'technology_indirect_cost', with: new_technology.indirect_cost
      fill_in 'technology_us_cost', with: new_technology.us_cost
      fill_in 'technology_local_cost', with: new_technology.local_cost

      click_submit

      expect(page).to have_content 'Data: All Technologies'
      expect(page).to have_link new_technology.name
    end
  end

  context '#edit' do
    before :each do
      @technology = FactoryBot.create(:technology)
    end

    it 'is linked from /technologies/:id' do
      visit technology_path(@technology)

      expect(page).to have_content "Data: #{@technology.name}"
      expect(page).to have_link 'Edit'
    end

    it 'edits a technology' do
      visit edit_technology_path(@technology)

      expect(page).to have_content 'Editing technology'

      fill_in 'technology_name', with: 'Capybara Filter'

      click_submit

      expect(page).to have_content 'Data: All Technologies'
      expect(page).to have_link 'Capybara Filter'
    end
  end
end
