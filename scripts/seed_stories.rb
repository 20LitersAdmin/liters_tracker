# frozen_string_literal: true

a = Report.where.not(distributed: nil).where('date BETWEEN ? AND ?', '2019-01-01', '2019-12-31').limit(8).order('RANDOM()').pluck(:id)
b = Report.where.not(distributed: nil).where('date BETWEEN ? AND ?', '2018-01-01', '2018-12-31').limit(10).order('RANDOM()').pluck(:id)
c = Report.where.not(distributed: nil).where('date BETWEEN ? AND ?', '2017-01-01', '2017-12-31').limit(6).order('RANDOM()').pluck(:id)
d = Report.where.not(distributed: nil).where('date BETWEEN ? AND ?', '2016-01-01', '2016-12-31').limit(4).order('RANDOM()').pluck(:id)
e = Report.where.not(distributed: nil).where('date BETWEEN ? AND ?', '2015-01-01', '2015-12-31').limit(7).order('RANDOM()').pluck(:id)

rep_ids = a + b + c + d + e

reports = Report.where(id: rep_ids)

package = []
reports.each do |rep|
  package << rep.story_json
end

Story.create(
  package
)
