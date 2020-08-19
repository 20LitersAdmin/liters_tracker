# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build :user_viewer }

  describe 'has validations on' do
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

    it 'admin' do
      no_admin.valid?
      expect(no_admin.errors[:admin]).to match_array('is not included in the list')
    end
  end

  describe 'has an scopes for' do
    let(:admin) { create :user_admin }
    let(:reporter) { create :user_reports }
    let(:geographer) { create :user_geography }
    let(:contractor) { create :user_contracts }
    let(:technologist) { create :user_technology }

    context 'admins' do
      it 'shows only admin users' do
        expect(User.admins).to include admin
        expect(User.admins).not_to include user
        expect(User.admins).not_to include reporter
        expect(User.admins).not_to include geographer
        expect(User.admins).not_to include contractor
        expect(User.admins).not_to include technologist
      end
    end

    context 'report_managers' do
      it 'shows only admins and report_managers' do
        expect(User.report_managers).to include admin
        expect(User.report_managers).not_to include user
        expect(User.report_managers).to include reporter
        expect(User.report_managers).not_to include geographer
        expect(User.report_managers).not_to include contractor
        expect(User.report_managers).not_to include technologist
      end
    end

    context 'geography_managers' do
      it 'shows only admins and geography_managers' do
        expect(User.geography_managers).to include admin
        expect(User.geography_managers).not_to include user
        expect(User.geography_managers).not_to include reporter
        expect(User.geography_managers).to include geographer
        expect(User.geography_managers).not_to include contractor
        expect(User.geography_managers).not_to include technologist
      end
    end

    context 'contract_managers' do
      it 'shows only admins and contract_managers' do
        expect(User.contract_managers).to include admin
        expect(User.contract_managers).not_to include user
        expect(User.contract_managers).not_to include reporter
        expect(User.contract_managers).not_to include geographer
        expect(User.contract_managers).to include contractor
        expect(User.contract_managers).not_to include technologist
      end
    end

    context 'technology_managers' do
      it 'shows only admins and technology_managers' do
        expect(User.technology_managers).to include admin
        expect(User.technology_managers).not_to include user
        expect(User.technology_managers).not_to include reporter
        expect(User.technology_managers).not_to include geographer
        expect(User.technology_managers).not_to include contractor
        expect(User.technology_managers).to include technologist
      end
    end
  end

  describe '#name' do
    it 'combines fname and lname in a string' do
      expect(user.name).to eq "#{user.fname} #{user.lname}"
    end
  end

  describe '#report_manager?' do
    let(:admin) { create :user_admin }
    let(:reporter) { create :user_reports }

    context 'when admin' do
      it 'returns true' do
        expect(admin.report_manager?).to eq true
      end
    end

    context 'when can_manage_reports: true' do
      it 'returns true' do
        expect(reporter.report_manager?).to eq true
      end
    end

    context 'when can_manage_reports: false' do
      it 'returns false' do
        expect(user.report_manager?).to eq false
      end
    end
  end

  describe '#geography_manager?' do
    let(:admin) { create :user_admin }
    let(:geographer) { create :user_geography }

    context 'when admin' do
      it 'returns true' do
        expect(admin.geography_manager?).to eq true
      end
    end

    context 'when can_manage_geography: true' do
      it 'returns true' do
        expect(geographer.geography_manager?).to eq true
      end
    end

    context 'when can_manage_geography: false' do
      it 'returns false' do
        expect(user.geography_manager?).to eq false
      end
    end
  end

  describe '#contract_manager?' do
    let(:admin) { create :user_admin }
    let(:contractor) { create :user_contracts }

    context 'when admin' do
      it 'returns true' do
        expect(admin.contract_manager?).to eq true
      end
    end

    context 'when can_manage_contracts: true' do
      it 'returns true' do
        expect(contractor.contract_manager?).to eq true
      end
    end

    context 'when can_manage_contracts: false' do
      it 'returns false' do
        expect(user.contract_manager?).to eq false
      end
    end
  end

  describe '#technology_manager?' do
    let(:admin) { create :user_admin }
    let(:technologist) { create :user_technology }

    context 'when admin' do
      it 'returns true' do
        expect(admin.technology_manager?).to eq true
      end
    end

    context 'when can_manage_technologies: true' do
      it 'returns true' do
        expect(technologist.technology_manager?).to eq true
      end
    end

    context 'when can_manage_technologies: false' do
      it 'returns false' do
        expect(user.technology_manager?).to eq false
      end
    end
  end
end
