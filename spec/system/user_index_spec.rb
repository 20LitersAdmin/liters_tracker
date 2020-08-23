# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User index', type: :system do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)
  end

  it 'shows all users' do
    3.times { FactoryBot.create(:user_viewer, confirmed_at: Time.now - 1.hour) }

    visit '/users'

    expect(page).to have_content 'All users'

    expect(page).to have_content User.first.name
    expect(page).to have_content User.second.name
    expect(page).to have_content User.third.name

    expect(page).to have_link 'Edit', count: 4
    expect(page).to have_link 'Destroy', count: 3
  end

  it 'has links for editing and destroying users' do
    @user = FactoryBot.create(:user_viewer, confirmed_at: Time.now - 1.hour)

    visit users_path
    expect(page).to have_content 'All users'

    expect(page).to have_content @user.name
    expect(page).to have_link 'Edit', count: 2
    expect(page).to have_link 'Destroy', count: 1
  end

  it 'allows for user deletion' do
    @user = FactoryBot.create(:user_viewer, confirmed_at: Time.now - 1.hour)

    visit users_path

    expect(page).to have_content 'All users'

    expect(page).to have_content @user.name
    expect(page).to have_css "#destroy_user_#{@user.id}"

    find("#destroy_user_#{@user.id}").click

    expect(page).to have_content 'All users'

    expect { @user.reload }.to raise_error ActiveRecord::RecordNotFound
  end

  it 'doesn\'t allow a user to delete themselves' do
    visit users_path

    expect(page).to have_content 'All users'

    expect(page).to have_content @admin.name
    expect(page).to have_css "#edit_user_#{@admin.id}"
    expect(page).not_to have_css "#destroy_user_#{@admin.id}"
  end
end
