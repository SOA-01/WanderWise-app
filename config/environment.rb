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
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config() = Figaro.env

      configure :development, :test do
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
      end

      @db = Sequel.connect(ENV['DATABASE_URL'])
      def self.db() = @db
    end
    SECRETS = YAML.safe_load(File.read('config/secrets.yml'))
  end
end
