# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module WanderWise
  # Mapper class for transforming API data into FlightsEntity
  class FlightMapper
    def initialize(gateway)
      @gateway = gateway
    end

    # Find and map flight data to entity
    def find_flight(params)
      flight_data = @gateway.fetch_response(params) 
      if flight_data['data'].nil? || flight_data['data'].empty?
        raise 'No flight data available'  
      end
    
      flight_data['data'].map do |flight|
        departure_time = flight.dig('itineraries', 0, 'segments', 0, 'departure', 'at')
        price = flight.dig('price', 'total')
        airline = flight.dig('itineraries', 0, 'segments', 0, 'carrierCode')
        duration = flight.dig('itineraries', 0, 'duration')
        arrival_time = flight.dig('itineraries', 0, 'segments', 0, 'arrival', 'at')
        destination_location_code = flight.dig('itineraries', 0, 'segments', -1, 'arrival', 'iataCode')
        WanderWise::Flight.new(
          origin_location_code: flight.dig('itineraries', 0, 'segments', 0, 'departure', 'iataCode'),
          destination_location_code: destination_location_code,
          departure_date: departure_time.split('T').first,
          price: price.to_f,
          airline: airline,
          duration: duration,
          departure_time: departure_time.split('T').last,
          arrival_time: arrival_time.split('T').last
        )
      end
    end   

    def save_flight_info_to_yaml(params, file_path)
      flight_entities = find_flight(params)
      flight_hashes = self.class.convert_entities_to_hashes(flight_entities)
      self.class.ensure_directory_exists(file_path)
      self.class.write_to_yaml(file_path, flight_hashes)
      flight_entities
    end

    private

    def build_entity(flight_data)
      segments = self.class.fetch_segments(flight_data)
      return nil if self.class.connecting_flight?(segments)

      build_flights_entity(flight_data, segments)
    end

    def build_flights_entity(flight_data, segments)
      Flight.new(
        origin_location_code: self.class.extract_origin(segments),
        destination_location_code: self.class.extract_destination(segments),
        departure_date: self.class.extract_departure_date(segments),
        price: self.class.extract_price(flight_data),
        airline: self.class.extract_airline(segments),
        duration: self.class.extract_duration(segments),
        departure_time: self.class.extract_departure_time(segments),
        arrival_time: self.class.extract_arrival_time(segments)
      )
    end

    class << self
      def convert_entities_to_hashes(flight_entities)
        flight_entities.map(&:to_h)
      end

      def ensure_directory_exists(file_path)
        directory = File.dirname(file_path)
        FileUtils.mkdir_p(directory) unless Dir.exist?(directory)
      end

      def write_to_yaml(file_path, flight_hashes)
        File.open(file_path, 'w') do |file|
          file.write(flight_hashes.to_yaml)
        end
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

      def extract_price(flight_data)
        flight_data.dig('price', 'total').to_f
      end

      def extract_airline(segments)
        segments[0]['carrierCode']
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
end
