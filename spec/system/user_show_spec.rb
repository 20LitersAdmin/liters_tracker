# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User show', type: :system do
  before :each do
    sign_in @admin = FactoryBot.create(:user_admin, confirmed_at: Time.now - 1.hour)
    @user = FactoryBot.create(:user_viewer, confirmed_at: Time.now - 1.hour)
  end

  it 'redirects to /users/:id/edit' do
    visit "users/#{@user.id}"

    expect(page).to have_content "Edit #{@user.name} profile"
  end
end
