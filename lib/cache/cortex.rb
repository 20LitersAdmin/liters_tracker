# frozen_string_literal: true

require 'dalli'

module Cache
  class Cortex
    attr_reader :client

    def initialize(options = { expires_in: 1.day, compress: true })
      host = 'localhost:11211'
      if production?
        options = options.merge({ username: ENV['MEMCACHE_USERNAME'],
                                  password: ENV['MEMCACHE_PASSWORD'] })
        host = ENV['MEMCACHE_SERVERS']
      end
      @client = Dalli::Client.new(host, options)
    end

    def delete(key)
      @client.delete(key)
    end

    def get(key)
      value = nil
      begin
        value = @client.get(key)
      rescue Exception => e
        p 'if local development, install memcached: `brew install memcached && brew services start memcached`'
        raise e
      end
      value
    end

    def set(key, value)
      @client.set(key, value)
    end

    private

    def production?
      Rails.env == 'production'
    end
  end
end
