# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.1.0'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

gem 'ajax-datatables-rails'
gem 'aws-sdk-s3'
gem 'bootsnap', require: false
gem 'bootstrap', '~> 4'
gem 'bootstrap-will_paginate', '~> 1.0.0'
gem 'bootstrap4-datetime-picker-rails'
gem 'coffee-rails'
gem 'devise'
gem 'font-awesome-rails'
gem 'haml'
gem 'haml-rails'
gem 'jquery-datatables'
gem 'jquery-rails'
gem 'mini_magick'
gem 'momentjs-rails'
gem 'money-rails'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'
gem 'pundit'
gem 'rails', '>= 7'
gem 'simple_form'
gem 'tinymce-rails', '~> 5.1'
gem 'turbolinks', '~> 5.2'
gem 'uglifier', '>= 1.3.0'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'will_paginate', '~> 3.2.1'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'rubocop'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :development do
  gem 'letter_opener_web'
  gem 'pry-rails'
  gem 'rack-mini-profiler', require: false
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'capybara-slow_finder_errors'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'rspec-retry'
  gem 'rspec_junit_formatter'
  gem 'shoulda-matchers'
  gem 'webdrivers'
end

group :production do
  gem 'rails_12factor'
end
