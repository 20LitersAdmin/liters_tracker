# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Logout function', type: :system do
  before :each do
    sign_in @user = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)
    visit '/data'
  end

  it 'is available as a link' do
    expect(page).to have_content "Hey #{@user.fname}"
    expect(page).to have_link 'Sign Out'
  end

  it 'signs out the active user' do
    click_link 'Sign Out'

    expect(page).to have_content 'See Our Progress'

    click_link 'data'

    expect(page).to have_content 'Log in'
    expect(page).to have_content 'You need to sign in first'
  end
end
