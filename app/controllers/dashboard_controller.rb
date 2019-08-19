# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @lifetime_stats = Technology.report_worthy.map do |technology|
      next if technology.lifetime_impact.zero?

      { stat: technology.lifetime_impact, title: "#{technology.name}s" }
    end

    @global_impact = Report.all.sum(:people)
  end
end
