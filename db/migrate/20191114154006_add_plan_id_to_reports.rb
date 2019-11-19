# frozen_string_literal: true

class AddPlanIdToReports < ActiveRecord::Migration[6.0]
  def change
    add_reference :reports, :plan, foreign_key: true
  end
end
