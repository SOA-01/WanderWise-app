# frozen_string_literal: true

require 'yaml'
require 'fileutils'

require_relative 'FlightsAPI'

module WanderWise
  # Handles logic outside the API calls
  class FlightsEntity
    @api = nil
    def initialize
      @api = FlightsAPI.new
    end

    def example_flight_info
      # Get the flights

      params = {
        originLocationCode: 'TPE',
        destinationLocationCode: 'LAX',
        departureDate: '2024-10-19',
        adults: 1
      }

      @api.fetch_response(params)

      # @api.fetch_flight_offers('TPE', 'LAX', '2024-10-19', 1)
    end

    def yaml_flight_info
      flight_offers = example_flight_info

      # FileUtils.mkdir_p('./spec/fixtures') unless Dir.exist?('./spec/fixtures')
      File.open('./spec/fixtures/flight-offers-results.yml', 'w') do |file|
        file.write(flight_offers.to_yaml)
      end
    end
  end
end
