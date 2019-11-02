package = []
Report.limit(200).each do |rep|
  package << rep.story_json
end

Story.create(
  package
)
