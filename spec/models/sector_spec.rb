# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sector, type: :model do
  let(:sector) { build :sector }

  context 'has validations on' do
    let(:no_name) { build :sector, name: nil }
    let(:no_district) { build :sector, district: nil }
    let(:bad_district) { build :sector, district_id: 999 }
    let(:no_gis) { build :sector, gis_code: nil }
    let(:duplicate_gis) { build :sector }

    it 'name' do
      no_name.valid?

      expect(no_name.errors[:name]).to match_array("can't be blank")

      no_name.name = 'has a name'
      no_name.valid?

      expect(no_name.errors.any?).to eq false
    end

    it 'district' do
      no_district.valid?
      expect(no_district.errors[:district_id]).to match_array("can't be blank")

      bad_district.valid?
      expect(bad_district.errors[:district]).to match_array('must exist')
    end

    context 'gis_code' do
      it 'can be blank' do
        no_gis.valid?
        expect(no_gis.errors.any?).to eq false
      end

      it 'must be unique' do
        sector.update(gis_code: 1)
        duplicate_gis.gis_code = 1

        duplicate_gis.valid?
        expect(duplicate_gis.errors[:gis_code]).to match_array('has already been taken')
      end
    end
  end
end
