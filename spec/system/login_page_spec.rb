# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Login page', type: :system do
  before :each do
    @user = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)
    visit '/'
    click_link 'data'
  end

  it 'loads the page' do
    expect(page).to have_content 'Log in'
  end

  context 'has the login form which' do
    it 'can be filled out' do
      expect(page).to have_field 'user_email'
      expect(page).to have_field 'user_password'
      expect(page).to have_button 'Log in'
    end

    it 'logs in users' do
      fill_in 'user_email', with: @user.email
      fill_in 'user_password', with: 'password'
      click_submit

      expect(page).to have_content "Hey #{@user.fname}"
    end
  end
end
