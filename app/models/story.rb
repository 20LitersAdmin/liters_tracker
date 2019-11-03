# frozen_string_literal: true

class Story < ApplicationRecord
  belongs_to :report, inverse_of: :story

  scope :between_dates, ->(start_date, end_date) { joins(:report).where('reports.date BETWEEN ? AND ?', start_date, end_date)}

  def self.array_of_unique_dates
    joins(:report).order('reports.date ASC').pluck('reports.date').uniq
  end

  # helper function that can be used in the future to bin and sort all stories in the data base
  #
  #
  # OUTPUT:
  #
  #
  # all_stories = 
  #  {
  #
  #     "2019": {"Jac" .. "Dec"} .. "XXX": {"Jac" .. "Dec"}
  #  }
  #
  #
  def self.bin_all_stories
    binned_stories = {} # variable for the final return of stories that are binned by month
    months = Date.const_get(:ABBR_MONTHNAMES).compact # returns nil as the first entry, so use compact to remove it
    years = self.get_story_years
    years.each do |y|
      tmp_hash = {}
      (1..12).step(1) do |m|
        # start with the first month and build a hash of all stories that are binned by a month
        tmp_date = Date.new(y, m)
        tmp_stories = self.between_dates(tmp_date.beginning_of_month, tmp_date.end_of_month)
        tmp_hash[Date.const_get(:ABBR_MONTHNAMES)[m]] = tmp_stories #convert digit to abbreviated month name
      end
      binned_stories[y.to_s] = tmp_hash # store off the hashes of stories associated by month and year
    end
    binned_stories
  end


  def self.bin_stories_by_year(year)
    story_collection = nil
    stories_by_month = {}
    month_list = []
    (1..12).step(1) do |m|
      tmp_hash = {}
      tmp_date = Date.new(year, m)
      # start with the first month and build a hash of all stories that are binned by a month
      tmp_stories = self.between_dates(tmp_date.beginning_of_month, tmp_date.end_of_month)
      if tmp_stories.size > 0 # check if there are stories for this month
        month_list << Date.const_get(:ABBR_MONTHNAMES)[m]
        if story_collection.nil?
          story_collection = tmp_stories # combine all the active record collections for the year
        else
          story_collection += tmp_stories
        end
        stories_by_month[Date.const_get(:ABBR_MONTHNAMES)[m]] = tmp_stories #convert digit to abbreviated month name
      end
    end
    return story_collection, month_list, stories_by_month # return the whole collection of stories, the months where stories exists, and later if needed a hash where key=month, value=ActiveRecord collection
  end

  def self.get_story_years
    self.array_of_unique_dates.map(&:year).uniq.sort.reverse
  end

  def picture
    image.blank? ? 'story_no_image.png' : image
  end

end
