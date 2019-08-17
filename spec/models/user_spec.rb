# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build :user_viewer }

  context 'has validations on' do
    let(:no_fname) { build :user_viewer, fname: nil }
    let(:no_lname) { build :user_viewer, lname: nil }
    let(:no_email) { build :user_viewer, email: nil }
    let(:dup_email) { build :user_viewer }
    let(:no_admin) { build :user_admin, admin: nil }

    it 'fname' do
      no_fname.valid?
      expect(no_fname.errors[:fname]).to match_array("can't be blank")
    end

    it 'lname' do
      no_lname.valid?
      expect(no_lname.errors[:lname]).to match_array("can't be blank")
    end

    it 'email' do
      no_email.valid?
      expect(no_email.errors[:email]).to match_array("can't be blank")

      user.save
      dup_email.email = user.email
      dup_email.valid?
      expect(dup_email.errors[:email]).to match_array('has already been taken')
    end
  end

  context 'has an admin scope' do
    let(:admin) { create :user_admin }
    let(:reporter) { create :user_reports}
    let(:geographer) { create :user_geography }
    let(:contractor) { create :user_contracts }
    let(:technologist) { create :user_technology }

    it 'that shows only admin users' do
      expect(User.admins).to include admin
      expect(User.admins).not_to include user
      expect(User.admins).not_to include reporter
      expect(User.admins).not_to include geographer
      expect(User.admins).not_to include contractor
      expect(User.admins).not_to include technologist
    end
  end

  context '.name' do
    it 'combines fname and lname in a string' do
      expect(user.name).to eq "#{user.fname} #{user.lname}"
    end
  end
end
