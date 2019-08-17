# LITERS TRACKER
A custom reporting app for 20 Liters.

# Contributing
To contribute please look at the open Issues and create a Pull Request with the solution. If you have any questions about the Project please reach out to Chip. All Pull Requests must be approved by a maintainer before being merged in.

## Developer Setup

**MacOS**
```
rbenv local 2.4.5
gem install bundler
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rails s
```
