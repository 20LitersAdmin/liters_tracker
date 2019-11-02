# frozen_string_literal: true

class Story < ApplicationRecord
  belongs_to :report

  scope :get_stories_by_year, ->(year_string) { joins(:report).where('reports.date BETWEEN ? AND ?', "#{year_string}-01-01", "#{year_string}-12-31")}
  scope: :stories_by_month

end
