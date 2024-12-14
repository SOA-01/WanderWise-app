# frozen_string_literal: true

require 'dry/transaction'

module WanderWise
  module Service
    class AddFlights # rubocop:disable Style/Documentation
      include Dry::Transaction

      step :validate_input
      step :fetch_flights

      private

      def validate_input(input)
        # Adjust the parameter names to match the service's expected keys
        input = transform_keys(input)

        # Ensure required parameters are present
        if input[:originLocationCode] && input[:destinationLocationCode] && input[:departureDate]
          Success(input)
        else
          Failure('Invalid input data')
        end
      end

      def fetch_flights(input)
        @api_gateway = WanderWise::Gateway::Api.new(WanderWise::App.config)
        response = @api_gateway.fetch_flights(input)

        if response.success?
          Success(response.payload)
        else
          Failure('Could not fetch flights')
        end
      end

      # Helper to ensure keys match the expected ones in the service
      def transform_keys(input)
        input.transform_keys do |key|
          case key
          when :originLocationCode then :originLocationCode
          when :destinationLocationCode then :destinationLocationCode
          when :departureDate then :departureDate
          when :adults then :adults
          else key
          end
        end
      end
    end
  end
end
