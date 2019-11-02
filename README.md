# LITERS TRACKER

A custom reporting app for 20 Liters.
*Built with love by [Code for Good West Michigan](https://codeforgoodwm.org/)*

## Contributing

To contribute please look at the open Issues and create a Pull Request with the solution. If you have any questions about the Project please reach out to Chip. All Pull Requests must be approved by a maintainer before being merged in.

## Developer Setup

**MacOS**

```
rbenv local 2.5.3
gem install bundler
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed #local seed optional
bundle exec rails s
```

**Testing emails**
Install https://github.com/mailhog/MailHog for a useful local SMTP server

## Production Database Restore

### Requirements

[Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli)

[Parity](https://github.com/thoughtbot/parity) - N.B. This only works for Postgres databases

Permissions to the 20 Liters Heroku App, and a `git remote` named `production` that points to the Heroku repo (see https://github.com/thoughtbot/parity#convention)

### Restore to Local Development Database

If using a traditional Postgres installation (including using Homebrew) then running `development restore_from production` will pull down an up-to-date backup from the production Postgres instance and run a wipe/restore on the local database.

Otherwise the environment variables `PGHOST`, `PGPORT`, and `PGUSER` can be set before running the restoration script to configure different development database setups.

E.g. Running on docker with Postgres defaults (`docker run --name 20liters_db -v 20liters_db_data:/var/lib/postgresql/data -d postgres:10.10-alpine`), then `PGHOST` will need to be set to `localhost` and `PGUSER` will need to be set to `postgres`.
