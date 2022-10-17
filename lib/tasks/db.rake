# frozen_string_literal: true

require 'net/http'
require 'uri'

namespace :db do
  desc 'Downloads the Production database from Railway and loads the data into production'
  task parity: :environment do
    # check for psql installed
    unless system('psql -V')
      puts '===> psql not found or not installed'
      return
    end

    pg_creds = Rails.application.credentials.railway.pg

    `pg_dump -a -F t --dbname=#{pg_creds.url} > latest_dump`

    puts '===> Got the production database'

    pg_vars = ActiveRecord::Base.connection_db_config.configuration_hash

    `pg_restore -O -F t --disable-triggers --dbname=postgresql://#{pg_vars[:user]}@127.0.0.1:#{pg_vars[:port]}/#{pg_vars[:database]} latest_dump`

    puts '===> Restored the production database to development'

    `rails db:migrate`

    `rm latest_dump`
  end
end
