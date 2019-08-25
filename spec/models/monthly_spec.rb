# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Monthly, type: :model do
  before :each do
    @monthly = Monthly.new
  end

  context 'validates presence of' do
    it 'year' do
      @monthly.year = nil
      expect(@monthly.valid?).to eq false
      expect(@monthly.errors[:year]).to match_array("can't be blank")
    end

    it 'month' do
      @monthly.month = nil
      expect(@monthly.valid?).to eq false
      expect(@monthly.errors[:month]).to match_array("can't be blank")
    end
  end
end
