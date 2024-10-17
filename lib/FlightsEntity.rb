require 'yaml'
require 'fileutils'

require_relative 'FlightsAPI'

module WanderWise
  class FlightsEntity
    @api = nil
    def initialize
        @api = FlightsAPI.new
    end

    def getFlightInfo
      # Get the flights
        @api.fetch_flight_offers('TPE', 'LAX', '2024-10-19', 1)

    end

    def yamlFlightInfo 
        flight_offers = getFlightInfo


        # FileUtils.mkdir_p('./spec/fixtures') unless Dir.exist?('./spec/fixtures')
        File.open('./spec/fixtures/flight-offers-results.yml', 'w') do |file|
            file.write(flight_offers.to_yaml)
          end
    end

  end
end