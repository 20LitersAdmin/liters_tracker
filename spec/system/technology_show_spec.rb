# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Technology show', type: :system do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)

    @technology = FactoryBot.create(:technology)

    visit technology_path(@technology)
  end

  it 'shows the technology' do
    expect(page).to have_content "Data: #{@technology.name}"
  end

  it 'has the search bar' do
    expect(page).to have_css('#search')
  end
end
