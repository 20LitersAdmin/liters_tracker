# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Story, type: :model do
  let(:story) { build :story }

  describe 'has validations on' do
    let(:no_title) { build :story, title: nil }
    let(:no_text) { build :story, text: nil }

    context 'title' do
      it 'must be present' do
        no_title.valid?
        expect(no_title.errors[:title]).to match_array("can't be blank")
      end
    end

    context 'text' do
      it 'must be present' do
        no_text.valid?
        expect(no_text.errors[:text]).to match_array("can't be blank")
      end
    end
  end

  describe 'has scopes for' do
    context '#between_dates' do
      let(:report_a) { create :report_facility, date: '2019-01-01' }
      let(:report_b) { create :report_facility, date: '2019-02-01' }
      let(:report_c) { create :report_facility, date: '2019-03-01' }
      let(:report_d) { create :report_facility, date: '2019-04-01' }

      let(:story_a) { create :story, report: report_a }
      let(:story_b) { create :story, report: report_b }
      let(:story_c) { create :story, report: report_c }
      let(:story_d) { create :story, report: report_d }

      it 'returns a collection of Stories where their associated reports are between the dates' do
        report_a
        report_b
        report_c
        report_d
        story_a
        story_b
        story_c
        story_d

        dtstart = '2019-01-24'
        dtend = '2019-03-15'

        expect(Story.between_dates(dtstart, dtend)).not_to include story_a
        expect(Story.between_dates(dtstart, dtend)).to include story_b
        expect(Story.between_dates(dtstart, dtend)).to include story_c
        expect(Story.between_dates(dtstart, dtend)).not_to include story_d
      end
    end
  end

  describe '#related' do
    it 'returns stories related by technology' do
    end

    it 'returns stories related by sector' do
    end

    it 'returns stories related by date' do
    end

    it 'returns random stories to meet limit requirements' do
    end
  end
end
