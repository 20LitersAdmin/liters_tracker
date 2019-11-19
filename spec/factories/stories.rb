# frozen_string_literal: true

FactoryBot.define do
  factory :story do
    title { 'FactoryTitle' }
    text { '<p>The Factory default story is a bit boring. But <strong>it does have some styling!</strong> and <i>it looks pretty good</i> if we do say so ourselves.</p>' }
    image { 'https://factory.cloudfront.net/images/1234.jpg' }
    image_name { '1234.jpg' }
    association :report, factory: :report_facility
  end
end
