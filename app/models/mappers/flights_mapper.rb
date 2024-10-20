# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module WanderWise
  # Mapper class for transforming API data into FlightsEntity
  class FlightsMapper
    puts 'loaded'
    def initialize(gateway)
      @gateway = gateway
    end

    # Find and map flight data to entity
    def find_flight(params)
      flight_data = @gateway.fetch_response(params)
      flights = flight_data['data'].map { |flight| build_entity(flight) }.compact # Remove nil entries
      flights.sort_by { |flight| Time.parse("#{flight.departure_date}T#{flight.departure_time}") }
    end

    def save_flight_info_to_yaml(params, file_path)
      flight_entities = find_flight(params)
      flight_hashes = flight_entities.map(&:to_h) # Convert each FlightsEntity to hash

      FileUtils.mkdir_p(File.dirname(file_path)) unless Dir.exist?(File.dirname(file_path))

      File.open(file_path, 'w') do |file|
        file.write(flight_hashes.to_yaml)
      end

      flight_entities
    end

    private

    def build_entity(flight_data)
      segments = fetch_segments(flight_data)

      return nil if connecting_flight?(segments)

      FlightsEntity.new(
        origin_location_code: extract_origin(segments),
        destination_location_code: extract_destination(segments),
        departure_date: extract_departure_date(segments),
        adults: count_adults(flight_data),
        price: extract_price(flight_data),
        airline: extract_airline(segments),
        flight_number: extract_flight_number(segments),
        duration: extract_duration(segments),
        departure_time: extract_departure_time(segments),
        arrival_time: extract_arrival_time(segments)
      )
    end

    def fetch_segments(flight_data)
      flight_data.dig('itineraries', 0, 'segments')
    end

    def connecting_flight?(segments)
      segments.size > 1
    end

    def extract_origin(segments)
      segments[0].dig('departure', 'iataCode')
    end

    def extract_destination(segments)
      segments[0].dig('arrival', 'iataCode')
    end

    def extract_departure_date(segments)
      segments[0].dig('departure', 'at').split('T').first
    end

    def count_adults(flight_data)
      flight_data['travelerPricings'].size
    end

    def extract_price(flight_data)
      flight_data.dig('price', 'total').to_f
    end

    def extract_airline(segments)
      segments[0]['carrierCode']
    end

    def extract_flight_number(segments)
      segments[0]['number']
    end

    def extract_duration(segments)
      segments[0]['duration']
    end

    def extract_departure_time(segments)
      segments[0]['departure']['at'].split('T').last
    end

    def extract_arrival_time(segments)
      segments[0]['arrival']['at'].split('T').last
    end
  end
end
