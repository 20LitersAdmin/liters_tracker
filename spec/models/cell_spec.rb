# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Cell, type: :model do
  let(:cell) { build :cell }

  context 'has validations on' do
    let(:no_name) { build :cell, name: nil }
    let(:no_sector) { build :cell, sector_id: nil }

    it 'name' do
      no_name.valid?
      expect(no_name.errors[:name]).to match_array("can't be blank")

      no_name.name = 'Has a name'
      no_name.valid?

      expect(no_name.errors.any?).to eq false
    end

    it 'sector_id' do
      no_sector.valid?
      expect(no_sector.errors[:sector_id]).to match_array("can't be blank")

      no_sector.sector_id = 2
      no_sector.valid?

      expect(no_sector.errors[:sector]).to match_array('must exist')

      sector = FactoryBot.create(:sector)
      no_sector.sector = sector
      no_sector.valid?

      expect(no_sector.errors.any?).to eq false
    end

    context 'gis_code which' do
      let(:duplicate_gis) { build :cell }

      it 'can be nil' do
        expect(cell.gis_code).to eq nil
        cell.valid?

        expect(cell.errors.any?).to eq false
      end

      it 'must be unique' do
        cell.update(gis_code: 1)
        duplicate_gis.gis_code = 1
        duplicate_gis.valid?

        expect(duplicate_gis.errors[:gis_code]).to match_array('has already been taken')
      end
    end
  end
end
