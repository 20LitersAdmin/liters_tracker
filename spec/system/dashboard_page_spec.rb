# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboard page', type: :system do
  context 'as any user' do
    before :each do
      3.times { FactoryBot.create(:story) }
      visit '/'
    end

    it 'loads the page' do
      expect(page).to have_content 'See Our Progress'
    end

    it 'shows the lifetime stats block' do
      expect(page).to have_selector(:css, 'div#lifetime_stats')
    end

    it 'shows the date navs' do
      expect(page).to have_selector(:css, 'div#date_navs')
    end

    it 'shows stories' do
      expect(page).to have_selector(:css, 'a.story', count: 3)
    end

    it 'shows the data link' do
      expect(page).to have_link 'data'
    end
  end
end
