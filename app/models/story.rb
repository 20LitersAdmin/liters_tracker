# frozen_string_literal: true

class Story < ApplicationRecord
  belongs_to :report

  scope :between_dates, ->(start_date, end_date) { joins(:report).where('reports.date BETWEEN ? AND ?', start_date, end_date)}

  def self.array_of_unique_dates
    joins(:report).order('reports.date ASC').pluck('reports.date').uniq
  end

end
