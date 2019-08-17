# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Village, type: :model do
  let(:village) { build :village }

  context 'has validations on' do
    let(:no_name) { build :village, name: nil }
    let(:no_cell) { build :village, cell: nil }
    let(:bad_cell) { build :village, cell_id: 999 }
    let(:no_gis) { build :village, gis_code: nil }
    let(:duplicate_gis) { build :village }

    it 'name' do
      no_name.valid?
      expect(no_name.errors[:name]).to match_array "can't be blank"
    end

    it 'cell' do
      no_cell.valid?
      expect(no_cell.errors[:cell_id]).to match_array "can't be blank"

      bad_cell.valid?
      expect(bad_cell.errors[:cell]).to match_array 'must exist'
    end

    context 'gis_code' do
      it 'can be blank' do
        no_gis.valid?
        expect(no_gis.errors.any?).to eq false
      end

      it "can't be duplicated" do
        village.update(gis_code: 21)
        duplicate_gis.gis_code = 21
        duplicate_gis.valid?

        expect(duplicate_gis.errors[:gis_code]).to match_array 'has already been taken'
      end
    end
  end

  describe '.pop_hh' do
    it 'displays a string with the population and household' do
      village.update(population: 10, households: 3)

      expect(village.pop_hh).to eq '10 / 3'
    end
  end

  describe '.village' do
    it 'returns itself' do
      village.save
      expect(village.village).to eq village
    end
  end
end
