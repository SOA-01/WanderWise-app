# frozen_string_literal: true

require 'roda'
require 'yaml'
require 'figaro'
require 'sequel'

module WanderWise
  # Configuration for the WanderWise app
  class App < Roda
    plugin :environments

    configure do
      if environment == :production
        # In production, use environment variables directly
        def self.config
          OpenStruct.new(
            amadeus_client_id: ENV['amadeus_client_id'],
            amadeus_client_secret: ENV['amadeus_client_secret'],
            nytimes_api_key: ENV['nytimes_api_key'],
            database_url: ENV['DATABASE_URL']
          )
        end
      else
        # For non-production environments, load secrets from YAML file
        Figaro.application = Figaro::Application.new(
          environment: environment,
          path: File.expand_path('config/secrets.yml')
        )
        Figaro.load
        def self.config = Figaro.env

        ENV['DATABASE_URL'] ||= "sqlite://#{config.DB_FILENAME}"
      end

      @db = Sequel.connect(config.database_url || ENV['DATABASE_URL'])
      class << self
        attr_reader :db
      end
    end
  end
end
