# frozen_string_literal: true

require 'http'
require 'yaml'
require 'json'
require_relative 'flights_entity'
require_relative 'nytimes_entity'

# ----- 1. Flight API -----
flight_entity = WanderWise::FlightsEntity.new
flight_entity.yaml_flight_info

# ----- 2. NY API ----- # Change the keyword to what you want
times_entity = WanderWise::NYTimesEntity.new
times_entity.save_articles_to_yaml
