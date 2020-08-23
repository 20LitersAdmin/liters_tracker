# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User form', type: :system do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)
  end

  context '#new' do
    it 'is linked from /users' do
      visit '/users'
      expect(page).to have_content 'All users'
      expect(page).to have_link 'New User'

      click_link 'New User'

      expect(page).to have_content 'New user'
      expect(page).to have_button 'Create User'
    end

    it 'has necessary fields' do
      visit '/users/new'
      expect(page).to have_content 'New user'
      expect(page).to have_field 'user_fname'
      expect(page).to have_field 'user_lname'
      expect(page).to have_field 'user_email'
      expect(page).to have_field 'user_admin'
      expect(page).to have_field 'user_can_manage_reports'
      expect(page).to have_field 'user_can_manage_geography'
      expect(page).to have_field 'user_can_manage_contracts'
      expect(page).to have_field 'user_can_manage_technologies'
      expect(page).to have_field 'user_confirmed_at'
      expect(page).to have_field 'user_locked_at'
      expect(page).to have_field 'user_password'
      expect(page).to have_field 'user_password_confirmation'
      expect(page).to have_button 'Create User'
    end

    it 'creates a user' do
      new_user = FactoryBot.build(:user_viewer)

      visit new_user_path

      expect(page).to have_content 'New user'
      fill_in 'user_fname', with: new_user.fname
      fill_in 'user_lname', with: new_user.lname
      fill_in 'user_email', with: new_user.email
      fill_in 'user_confirmed_at', with: Time.now.to_s
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'

      click_submit

      expect(page).to have_content 'All users'
      expect(page).to have_content new_user.name
      expect(page).to have_content new_user.email
    end
  end

  context '#edit' do
    before :each do
      @user = FactoryBot.create(:user_viewer, confirmed_at: Time.now - 1.hour)
    end

    it 'is linked from /users' do
      visit '/users'

      expect(page).to have_content 'All users'
      expect(page).to have_content @user.name
      expect(page).to have_link 'Edit'

      click_link "edit_user_#{@user.id}"

      expect(page).to have_content "Edit #{@user.name} profile"
    end

    it 'edits a user' do
      visit edit_user_path(@user)

      expect(page).to have_content "Edit #{@user.name} profile"
      fill_in 'user_fname', with: 'Capybara'
      click_submit

      expect(page).to have_content 'All users'
      expect(@user.reload.fname).to eq 'Capybara'
    end
  end
end
