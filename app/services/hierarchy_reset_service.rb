# frozen_string_literal: true

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
