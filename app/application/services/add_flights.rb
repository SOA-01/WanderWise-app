# frozen_string_literal: true

require 'dry/transaction'

module WanderWise
  module Service
    class AddFlights
      include Dry::Transaction

      step :validate_input
      step :fetch_flights
      step :store_flights

      def initialize(api_gateway)
        @api_gateway = api_gateway
      end

      private

      def validate_input(input)
        # Adjust the parameter names to match the service's expected keys
        input = transform_keys(input)

        # Ensure required parameters are present
        if input[:origin_location_code] && input[:destination_location_code] && input[:departure_date]
          Success(input)
        else
          Failure('Invalid input data')
        end
      end

      def fetch_flights(input)
        response = @api_gateway.fetch_flights(input)

        if response.success?
          Success(response.payload)
        else
          Failure('Could not fetch flights')
        end
      end

      def store_flights(input)
        Repository::For.klass(Entity::Flight).create_many(input)
        Success(input)
      rescue StandardError => e
        Failure("Could not save flight data: #{e.message}")
      end

      # Helper to ensure keys match the expected ones in the service
      def transform_keys(input)
        input.transform_keys do |key|
          case key
          when :originLocationCode then :origin_location_code
          when :destinationLocationCode then :destination_location_code
          when :departureDate then :departure_date
          when :adults then :adults
          else key
          end
        end
      end
    end
  end
end
