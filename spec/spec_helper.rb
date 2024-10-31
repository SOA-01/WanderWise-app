# frozen_string_literal: true

require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../app/controllers/app'
require_relative '../app/infrastructure/amadeus/gateways/amadeus_api'
require_relative '../app/infrastructure/nytimes/gateways/nytimes_api'
require_relative '../app/infrastructure/amadeus/mappers/flight_mapper'
require_relative '../app/infrastructure/nytimes/mappers/article_mapper'
require_relative '../app/models/entities/flight_entity'
require_relative '../app/models/entities/article_entity'

ENV['RACK_ENV'] = 'test'

curr_dir = __dir__
CORRECT_NYT = YAML.load_file("#{curr_dir}/fixtures/nytimes-results.yml")
CORRECT_FLIGHTS = YAML.load_file("#{curr_dir}/fixtures/flight-offers-results.yml")

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE_NYT = 'nyt_api'
CASSETTE_FILE_FLIGHTS = 'flights_api'
