# frozen_string_literal: true

require 'yaml'
require 'minitest/autorun'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../lib/gateways/flights_api'
require_relative '../lib/gateways/nytimes_api'
require_relative '../lib/entities/flights_entity'
require_relative '../lib/entities/nytimes_entity'

curr_dir = __dir__
CORRECT_NYT = YAML.load_file("#{curr_dir}/fixtures/nytimes-results.yml")
CORRECT_FLIGHTS = YAML.load_file("#{curr_dir}/fixtures/flight-offers-results.yml")

CASSETTES_FOLDER = 'spec/fixtures/cassettes'
CASSETTE_FILE_NYT = 'nyt_api'
CASSETTE_FILE_FLIGHTS = 'flights_api'
