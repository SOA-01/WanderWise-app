# frozen_string_literal: true

require_relative '../gateways/flights_api'
require_relative '../entities/flights_entity'

module WanderWise
  # Mapper class for transforming raw flight data into FlightsEntity
  class FlightsMapper
    def initialize(gateway)
      @gateway = gateway
    end

    # Finds and returns a single FlightsEntity object based on the search parameters
    def find_flight(params)
      # Fetch the raw data from the API using the gateway
      flight_data = @gateway.fetch_response(params)

      # Assume the first result is the most relevant; you can change this logic as needed
      build_entity(flight_data['data'].first)
    end

    private

    # Converts raw API data into a FlightsEntity object
    def build_entity(flight_data)
      # Extract relevant attributes from the raw data
      attributes = {
        origin_location_code: flight_data.dig('itineraries', 0, 'segments', 0, 'departure', 'iataCode'),
        destination_location_code: flight_data.dig('itineraries', 0, 'segments', 0, 'arrival', 'iataCode'),
        departure_date: flight_data.dig('itineraries', 0, 'segments', 0, 'departure', 'at').split('T').first,
        adults: flight_data['travelerPricings'].size,
        price: flight_data.dig('price', 'total').to_f,
        airline: flight_data.dig('itineraries', 0, 'segments', 0, 'carrierCode')
      }

      # Return the FlightsEntity object with the extracted attributes
      FlightsEntity.new(attributes)
    end
  end
end
