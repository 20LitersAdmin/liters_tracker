class DashboardController < ApplicationController

  def index
    @lifetime_stats = Technology.all.map do |technology|
      next if technology.lifetime_impact.zero?
      { stat: technology.lifetime_impact, title: technology.name }
    end
  end
end
