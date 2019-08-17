# frozen_string_literal: true

require 'rails_helper'

RSpec.describe District, type: :model do
  let(:district) { build :district }

  context 'has validations on' do
    let(:no_name) { build :district, name: nil }
    let(:no_gis) { build :district, gis_code: nil }
    let(:duplicate_gis) { build :district }

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
        district.update(gis_code: 1)

        duplicate_gis.gis_code = 1
        duplicate_gis.valid?

        expect(duplicate_gis.errors[:gis_code]).to match_array('has already been taken')
      end
    end
  end
end
