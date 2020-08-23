# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Contract index', type: :system do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)

    @contract = FactoryBot.create(:contract)
  end

  it 'shows the contract' do
    visit contract_path(@contract)

    expect(page).to have_content @contract.name
  end

  it 'shows targets' do
    3.times { FactoryBot.create(:target, contract: @contract) }

    visit contract_path(@contract)

    expect(page).to have_css 'table#targets_table tbody tr', count: 3
  end

  it 'shows plans through an ajaxed datatable' do
    visit contract_path(@contract)

    # Not asserting any actual records, trusting DataTables to AJAX them in as expected
    expect(page).to have_css 'table#plans-dttb'
  end
end
