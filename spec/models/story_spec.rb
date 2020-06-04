# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Story, type: :model do
  let(:story) { build :story }

  describe 'has validations on' do
    let(:no_title) { build :story, title: nil }
    let(:no_text) { build :story, text: nil }
    let(:no_report) { build :story, report_id: nil }

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

    context 'report' do
      it 'must be present' do
        no_report.valid?
        expect(no_report.errors[:report]).to match_array('must exist')
      end
    end
  end

  describe 'has scopes for' do
    let(:report_b) { create :report_facility, date: '2019-02-01' }
    let(:report_d) { create :report_facility, date: '2019-04-01' }
    let(:report_a) { create :report_facility, date: '2019-01-01' }
    let(:report_c) { create :report_facility, date: '2019-03-01' }

    let(:story_a) { create :story, report: report_a }
    let(:story_c) { create :story, report: report_c }
    let(:story_d) { create :story, report: report_d }
    let(:story_b) { create :story, report: report_b }

    context '.between_dates' do
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

        stories = Story.between_dates(dtstart, dtend)

        expect(stories).not_to include story_a
        expect(stories).to include story_b
        expect(stories).to include story_c
        expect(stories).not_to include story_d
      end
    end

    context '.ordered_by_date' do
      it 'orders stories by their associated report in descending order' do
        report_d
        report_b
        report_c
        report_a
        story_c
        story_a
        story_d
        story_b

        ordered_stories = Story.ordered_by_date

        expect(ordered_stories.first).to eq story_d
        expect(ordered_stories.second).to eq story_c
        expect(ordered_stories.third).to eq story_b
        expect(ordered_stories.fourth).to eq story_a
      end
    end
  end

  describe '#breadcrumb' do
    it 'calls #breadcrumb on the associated report' do
      story.save

      expect(story.report).to receive(:breadcrumb).exactly(1).times

      story.breadcrumb
    end
  end

  describe '#date' do
    it 'calls #date on the associated report' do
      story.save

      expect(story.report).to receive(:date).exactly(1).times

      story.date
    end
  end

  describe '#picture' do
    before :each do
      story.save
    end

    context 'when there is no image' do
      it 'returns a url for story_no_picture.png' do
        expect(story.image.present?).to eq false
        expect(story.picture[0..21]).to eq '/assets/story_no_image'
      end
    end

    context 'when an image is attached' do
      it 'returns a url for the image' do
        story.image.attach(io: File.open('./app/assets/images/SSF.png'), filename: 'test_img.png', content_type: 'image/png')

        expect(story.picture[0..26]).to eq '/rails/active_storage/blobs'
        expect(story.picture[-13..-1]).to eq '/test_img.png'
      end
    end
  end

  describe '#process_image!' do
    context 'when image_io is not an image' do
      it 'adds an error to story.image' do
        story.save
        image_io = fixture_file_upload('spec/fixtures/files/not_an_image_file.txt', 'text/plain')

        story.process_image!(image_io)

        expect(story.errors[:image][0]).to eq 'needs to be an image'
      end
    end

    context 'when image_io is an image' do
      before :each do
        story.save
        @image_io = fixture_file_upload('app/assets/images/SSF.png', 'image/png')
        story.process_image!(@image_io)
      end

      it 'utilizes MiniMagick\'s resize feature' do
        magick_double = instance_double('MiniMagick::Image.new')
        allow(story).to receive(:magick_image).and_return(magick_double)
        allow(magick_double).to receive(:resize).and_return(magick_double)

        expect(magick_double).to receive(:resize)

        story.process_image!(@image_io)
      end

      it 'resizes the image to 355 px wide' do
        expect(ActiveStorage::Analyzer::ImageAnalyzer.new(story.image).metadata[:width]).to eq 355
      end

      it 'renames the image to {report_id}_{report.date.year}-{report.date.month}' do
        report = story.report

        expect(story.image.filename.base).to eq "#{report.id}_#{report.date.year}-#{report.date.month}"
      end

      it 'attaches the image' do
        expect(story.image.attached?).to eq true
      end
    end
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

  describe '#rotate_image!' do
    before :each do
      story.save
    end

    context 'when direction is neither left nor right' do
      it 'returns false' do
        story.image.attach(io: File.open('./app/assets/images/SSF.png'), filename: 'test_img.png', content_type: 'image/png')
        expect(story.rotate_image!('upwards')).to eq false
      end
    end

    context 'when image is not attached' do
      it 'returns false' do
        expect(story.image.attached?).to eq false
        expect(story.rotate_image!('left')).to eq false
      end
    end

    context 'when direction is left or right and image is attached' do
      before :each do
        story.image.attach(io: File.open('./app/assets/images/SSF.png'), filename: 'test_img.png', content_type: 'image/png')
      end

      it 'utilizes MiniMagick\'s rotate feature' do
        magick_double = instance_double('MiniMagick::Image.new')
        allow(story).to receive(:magick_image).and_return(magick_double)
        allow(magick_double).to receive(:rotate).and_return(magick_double)

        expect(magick_double).to receive(:rotate).with(90)

        story.rotate_image!('right')
      end

      it 're-attaches the rotated image' do
        story.rotate_image!('left')

        expect(story.image.attached?).to eq true
      end
    end
  end

  private

  describe '#check_image_format' do
    it 'fires on validation' do
      story.save
      image_io = fixture_file_upload('app/assets/images/SSF.png', 'image/png')
      story.image.attach(io: File.open(image_io.tempfile.path), filename: 'test-check-image-format.png', content_type: image_io.content_type)
      expect(story).to receive(:check_image_format)

      story.valid?
    end

    context 'when the content_type starts with "image/"' do
      it 'returns true' do
        story.save
        image_io = fixture_file_upload('app/assets/images/SSF.png', 'image/png')
        story.image.attach(io: File.open(image_io.tempfile.path), filename: 'test-check-image-format.png', content_type: image_io.content_type)

        expect(story.send(:check_image_format)).to eq true
      end
    end

    context 'when the content_type doesn\'t start with "image/"' do
      before :each do
        story.save
        image_io = fixture_file_upload('spec/fixtures/files/not_an_image_file.txt', 'text/plain')
        story.image.attach(io: File.open(image_io.tempfile.path), filename: 'test-check-image-format.png', content_type: image_io.content_type)
      end

      it 'purges/deletes the image' do
        expect(story.image.attached?).to eq true
        story.send(:check_image_format)
        expect(story.reload.image.attached?).to eq false
      end

      it 'adds an error to :image' do
        expect(story.image.attached?).to eq true
        story.send(:check_image_format)
        expect(story.errors[:image][0]).to eq 'needs to be an image'
      end
    end
  end

  describe '#magick_image' do
    it 'initiates a new MiniMagick::Image object' do
      story.save
      expect(MiniMagick::Image).to receive(:new)
      story.send(:magick_image, 'somepath')
    end
  end
end
