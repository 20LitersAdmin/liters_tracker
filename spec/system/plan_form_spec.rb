# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Plan form', type: :system, js: true do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)
    @date = Date.today
    @contract = FactoryBot.create(:contract, start_date: @date - 1.year, end_date: @date + 1.year)
    @technology = FactoryBot.create(:technology_community)
    @sector = FactoryBot.create(:sector)
  end

  context '#new' do
    it 'begins with /contracts/:id, which leads to /contracts/:id/select' do
      visit contract_path(@contract)

      expect(page).to have_link 'Add Plan'

      click_link 'Add Plan'

      expect(page).to have_content 'Submit a plan for MOU #'
    end

    it 'date, technology and sector are set from /contracts/:id/select' do
      visit select_contract_path(@contract)

      expect(page).to have_content 'Submit a plan for MOU #'

      expect(page).to have_css 'select#date_month'
      expect(page).to have_css 'select#date_year'

      expect(page).to have_link @technology.short_name

      expect(page).to have_css 'table#sector_chooser'
      expect(page).to have_content @sector.name
    end

    it 'has the necessary fields' do
      visit plan_contract_path(@contract, date: @date.to_s, sect: @sector.id, tech: @technology.id)

      expect(page).to have_content "Plan for #{@technology.short_name} in #{@sector.name} Sector during #{@date.strftime('%B, %Y')}"

      expect(page).to have_field 'plan_cell'
      expect(page).to have_field 'plan_village'
      expect(page).to have_field 'plan_facility'
      expect(page).to have_field 'plan_date'
      expect(page).to have_field 'plan_goal'
      expect(page).to have_field 'plan_people_goal'
      expect(page).to have_button 'Save'
    end

    it 'creates the plan' do
      cell = FactoryBot.create(:cell, sector: @sector)
      village = FactoryBot.create(:village, cell: cell)
      facility = FactoryBot.create(:facility, village: village)

      new_plan = FactoryBot.build(:plan_facility, date: Date.today)
      visit plan_contract_path(@contract, date: @date.to_s, sect: @sector.id, tech: @technology.id)

      expect(page).to have_content "Plan for #{@technology.short_name} in #{@sector.name} Sector during #{@date.strftime('%B, %Y')}"

      select cell.name, from: 'plan_cell'
      select village.name, from: 'plan_village'
      select facility.name, from: 'plan_facility'
      fill_in 'plan_date', with: new_plan.date.to_s
      fill_in 'plan_goal', with: new_plan.goal
      fill_in 'plan_people_goal', with: new_plan.people_goal

      click_submit

      expect(page).to have_content 'Plan created.'
    end
  end

  context '#edit' do
    before :each do
      @cell = FactoryBot.create(:cell, sector: @sector)
      @village = FactoryBot.create(:village, cell: @cell)
      @facility = FactoryBot.create(:facility, village: @village)
      @plan = FactoryBot.create(:plan_facility, planable: @facility, technology: @technology, contract: @contract, date: @date)
    end

    it 'is linked from /contracts/:id/plan' do
      visit plan_contract_path(@contract, date: @date.to_s, sect: @sector.id, tech: @technology.id)

      expect(page).to have_content "Plan for #{@technology.short_name} in #{@sector.name} Sector during #{@date.strftime('%B, %Y')}"
      expect(page).to have_css 'table#dttb_contract_plans'
      expect(page).to have_link 'Edit', href: edit_contract_plan_path(@contract, @plan)
    end

    it 'is linked from /contracts/:id' do
      visit contract_path(@contract)

      expect(page).to have_content "Contract ##{@contract.name}"
      # this table uses DataTables ajax to pull records, so js: true is required for the spec
      expect(page).to have_css 'table#plans-dttb'
      expect(page).to have_link 'Edit', href: edit_contract_plan_path(@contract, @plan)
    end

    it 'edits a plan' do
      visit edit_contract_plan_path(@contract, @plan)

      expect(page).to have_content @plan.title

      fill_in 'plan_goal', with: 10

      click_submit

      expect(page).to have_content 'Plan updated.'
      expect(@plan.reload.goal).to eq 10
    end
  end
end
