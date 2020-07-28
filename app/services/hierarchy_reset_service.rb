# frozen_string_literal: true

class HierarchyResetService
  def self.go!
    puts 'Resetting all hierarchies...'
    District.all.each do |d|
      d.update_hierarchy(cascade: true)
    end
    puts 'Done!'
  end
end
