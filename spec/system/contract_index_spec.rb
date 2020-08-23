# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract index', type: :system do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)

    @first = FactoryBot.create(:contract, start_date: '2018-01-01', end_date: '2018-06-30')
    @second = FactoryBot.create(:contract, start_date: '2018-07-01', end_date: '2018-12-31')
    @third = FactoryBot.create(:contract, start_date: '2019-01-01', end_date: '2019-06-30')
  end

  it 'is accessed from /data' do
    visit data_path

    expect(page).to have_content 'Manage MOUs'
    expect(page).to have_link 'Go', href: '/contracts'
  end

  it 'shows all contracts' do
    visit contracts_path

    expect(page).to have_content @first.name
    expect(page).to have_content @second.name
    expect(page).to have_content @third.name
  end

  it 'has links for showing contracts' do
    visit contracts_path

    expect(page).to have_link @first.name
    expect(page).to have_link @second.name
    expect(page).to have_link @third.name
  end
end
