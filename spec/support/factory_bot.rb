# frozen_string_literal: true

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  FactoryBot.use_parent_strategy = false
end
