# frozen_string_literal: true

require 'dry/transaction'

module WanderWise
  module Service
    class AnalyzeFlights
      include Dry::Transaction

      step :validate_input
      step :analyze_flights

      private

      def validate_input(input)
        input.first.origin_location_code && input.first.destination_location_code ? Success(input) : Failure('Invalid flight data')
      end

      def analyze_flights(input)
        avg_price = Repository::For.klass(Entity::Flight).find_average_price_from_to(
          input.first.origin_location_code,
          input.first.destination_location_code
        ).round(2)

        best_price = Repository::For.klass(Entity::Flight).find_best_price_from_to(
          input.first.origin_location_code,
          input.first.destination_location_code
        )

        Success(historical_average_data: avg_price, historical_lowest_data: best_price)
      rescue StandardError
        Failure('Could not analyze flight data')
      end
    end
  end
end
