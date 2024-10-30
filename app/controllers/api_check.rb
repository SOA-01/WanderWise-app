# frozen_string_literal: true

require_relative '../models/gateways/flights_api'
require_relative '../models/gateways/nytimes_api'
require_relative '../models/mappers/flights_mapper'
require_relative '../models/mappers/nytimes_mapper'

module WanderWise
  # Main class to run the application logic
  class Main
    def self.run
      # ----- 1. Flight API -----
      flight_mapper = WanderWise::FlightsMapper.new(WanderWise::FlightsAPI.new)
      params = {
        originLocationCode: 'TPE',
        destinationLocationCode: 'LAX',
        departureDate: (Date.today + 7).strftime('%Y-%m-%d'),
        adults: 1
      }
      flight_mapper.save_flight_info_to_yaml(params, './spec/fixtures/flight-offers-results.yml')

      # ----- 2. NY Times API -----
      times_mapper = WanderWise::NYTimesMapper.new(WanderWise::NYTimesAPI.new)
      times_mapper.save_articles_to_yaml('Taiwan', './spec/fixtures/nytimes-results.yml')
    end
  end
end

# To execute the application logic
WanderWise::Main.run unless File.exist?('./spec/fixtures/flight-offers-results.yml') && File.exist?('./spec/fixtures/nytimes-results.yml')
