# frozen_string_literal: true

## =====> Hello, Interviewers!
#
# JSONb columns in postgres give me tree-like record hierarchy
# that keeps me from having to daisy-chain relationships
# Most of the models in this app are either part of a geographical
# hierarchy or related somehow to one point of geography, often in
# a polymorphic way.
#
# Storing some portion of the geographical hierarchy in each record
# Makes actions like generating breadcrumb links one database call
# Instead of many.
class HierarchyResetService
  def self.update_geographies!
    puts 'Resetting all geography hierarchies...'
    District.all.each do |d|
      d.update_hierarchy(cascade: true)
    end
    puts 'Done!'
  end

  def self.update_plans!
    puts 'Resetting all plan hierarchies...'
    Plan.all.each do |plan|
      plan.send(:update_hierarchy)
    end
    puts 'Done!'
  end

  def self.update_reports!
    puts 'Resetting all Report hierarchies...'
    Report.all.each do |report|
      report.send(:update_hierarchy)
    end
    puts 'Done!'
  end
end
