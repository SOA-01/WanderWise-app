# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
require 'dotenv'
Dotenv.load

require 'yaml'
require 'minitest/autorun'
require 'vcr'
require 'webmock'
require 'rack/test'

require_relative '../app/controllers/app'
require_relative '../app/infrastructure/amadeus/gateways/amadeus_api'
require_relative '../app/infrastructure/nytimes/gateways/nytimes_api'
require_relative '../app/infrastructure/amadeus/mappers/flight_mapper'
require_relative '../app/infrastructure/nytimes/mappers/article_mapper'
require_relative '../app/models/entities/flight'
require_relative '../app/models/entities/article'
require_relative 'database_helper'

ENV['RACK_ENV'] = 'test'
ENV['SESSION_SECRET'] = 'test_secret_key'

curr_dir = __dir__
CORRECT_NYT = YAML.load_file("#{curr_dir}/fixtures/nytimes-results.yml")
CORRECT_FLIGHTS = YAML.load_file("#{curr_dir}/fixtures/flight-offers-results.yml")

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE_NYT = 'nyt_api'
CASSETTE_FILE_FLIGHTS = 'flights_api'

VCR.configure do |config|
  config.cassette_library_dir = CASSETTES_FOLDER
  config.hook_into :webmock
  config.filter_sensitive_data('<AMAD_CLIENT_ID>') { ENV['AMADEUS_CLIENT_ID'] }
  config.filter_sensitive_data('<NYT_API_KEY>') { ENV['NYTIMES_API_KEY'] }
  config.configure_rspec_metadata!
end
