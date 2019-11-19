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
    context '.between_dates' do
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

    context '.ordered_by_date' do
      pending 'needs to be tested'
    end

    context 'with_images' do
      pending 'needs to be tested'
    end
  end

  describe '#date' do
    pending 'needs to be tested'
  end

  describe '#download_image' do
    pending 'needs to be tested'
  end

  describe '#image_localized?' do
    pending 'needs to be tested'
  end

  describe '#image_path' do
    pending 'needs to be tested'
  end

  describe '#image_right_sized?' do
    pending 'needs to be tested'
  end

  describe '#image_uploaded?' do
    pending 'needs to be tested'
  end

  describe '#localize_image!' do
    pending 'needs to be tested'
  end

  describe '#picture' do
    pending 'needs to be tested'
  end

  describe '#resize_image' do
    pending 'needs to be tested'
  end

  describe '#related' do
    before :each do
      story.save
    end

    it 'returns stories related by technology' do
      technology = story.report.technology
      report_technology = FactoryBot.create(:report_facility, technology: technology)
      story_technology = FactoryBot.create(:story, report: report_technology)

      expect(story.related).to include story_technology
    end

    it 'returns stories related by sector' do
      sector = story.report.reportable.sector
      report_sector = FactoryBot.create(:report_sector, reportable: sector)
      story_sector = FactoryBot.create(:story, report: report_sector)

      expect(story.related).to include story_sector
    end

    it 'returns stories related by date' do
      date = story.report.date
      report_date = FactoryBot.create(:report_village, date: date)
      story_date = FactoryBot.create(:story, report: report_date)

      expect(story.related).to include story_date
    end

    it 'returns random stories to meet limit requirements' do
      5.times do
        FactoryBot.create(:story)
      end

      expect(Story.all.size).to eq 6
      expect(story.related(3).size).to eq 3
    end

    it 'returns an empty set if limit is nil and no related stories are found' do
      expect(story.related.empty?).to eq true
      expect(story.related.is_a?(ActiveRecord::Relation)).to eq true
    end
  end

  describe '#rotate_image' do
    pending 'needs to be tested'
  end

  describe '#s3_image' do
    pending 'needs to be tested'
  end

  describe '#upload_image!' do
    pending 'needs to be tested'
  end

  private

  describe '#find_or_download_image' do
    pending 'needs to be tested'
  end

  describe '#delete_local_file' do
    pending 'needs to be tested'
  end
end
