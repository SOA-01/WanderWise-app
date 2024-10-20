# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module WanderWise
  # Mapper class for transforming API data into FlightsEntity
  class FlightsMapper
    puts "loaded"
    def initialize(gateway)
      @gateway = gateway
    end

    # Find and map flight data to entity
    def find_flight(params)
      flight_data = @gateway.fetch_response(params)
      build_entity(flight_data['data'].first)
    end

    def save_flight_info_to_yaml(params, file_path)
      flight_entity = find_flight(params)
      FileUtils.mkdir_p(File.dirname(file_path)) unless Dir.exist?(File.dirname(file_path))

      File.open(file_path, 'w') do |file|
        file.write(flight_entity.to_h.to_yaml)
      end

      flight_entity
    end

    private

    def build_entity(flight_data)
      FlightsEntity.new(
        origin_location_code: flight_data.dig('itineraries', 0, 'segments', 0, 'departure', 'iataCode'),
        destination_location_code: flight_data.dig('itineraries', 0, 'segments', 0, 'arrival', 'iataCode'),
        departure_date: flight_data.dig('itineraries', 0, 'segments', 0, 'departure', 'at').split('T').first,
        adults: flight_data['travelerPricings'].size,
        price: flight_data.dig('price', 'total').to_f,
        airline: flight_data.dig('itineraries', 0, 'segments', 0, 'carrierCode')
      )
    end
  end
end
