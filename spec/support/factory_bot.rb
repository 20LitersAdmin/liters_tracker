RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  FactoryBot.use_parent_strategy = false
end
