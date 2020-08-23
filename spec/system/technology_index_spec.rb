# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Technology index', type: :system do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)

    @fam_tech = FactoryBot.create(:technology_family)
    @com_tech = FactoryBot.create(:technology_community)
    @eng_tech = FactoryBot.create(:technology_engagement)

    visit technologies_path
  end

  it 'shows all technologies' do
    expect(page).to have_content 'Data: All Technologies'
    expect(page).to have_content @fam_tech.name
    expect(page).to have_content @com_tech.name
    expect(page).to have_content @eng_tech.name
  end

  it 'has the search bar' do
    expect(page).to have_css('#search')
  end
end
