# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Country, type: :model do
  let(:country) { build :country }

  context 'has validations on' do
    let(:no_name) { build :country, name: nil }
    let(:no_gis) { build :country, gis_code: nil }
    let(:duplicate_gis) { build :country }

    it 'name' do
      no_name.valid?

      expect(no_name.errors[:name]).to match_array("can't be blank")

      no_name.name = 'has a name'
      no_name.valid?

      expect(no_name.errors.any?).to eq false
    end

    context 'gis_code' do
      it 'can be blank' do
        no_gis.valid?

        expect(no_gis.errors.any?).to eq false
      end

      it "can't be a duplicate" do
        country.update(gis_code: 1)

        duplicate_gis.gis_code = 1
        duplicate_gis.valid?

        expect(duplicate_gis.errors[:gis_code]).to match_array('has already been taken')
      end
    end
  end

  context 'country' do
    it 'returns itself, because I need all Geography models to respond to record.country' do
      expect(country.country).to eq country
    end
  end
end
