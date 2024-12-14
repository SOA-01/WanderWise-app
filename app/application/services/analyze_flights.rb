# frozen_string_literal: true

require 'dry/transaction'

module WanderWise
  module Service
    # Service to analyze flight data
    class AnalyzeFlights
      include Dry::Transaction

      step :analyze_flights

      private

      def analyze_flights(input)
        @api_gateway = WanderWise::Gateway::Api.new(WanderWise::App.config)
        response = @api_gateway.analyze_flight(input)

        if response.success?
          Success(response.payload)
        else
          Failure('Could not analyze flight data')
        end
      end
    end
  end
end
