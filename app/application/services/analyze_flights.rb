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
        historical_average_data = historical_average(input)
        historical_lowest_data = historical_lowest(input)

        Success(historical_average_data: historical_average_data.value!,
                historical_lowest_data: historical_lowest_data.value!)
      rescue StandardError
        Failure('Could not analyze flight data')
      end

      def historical_average(input)
        input = Repository::For.klass(Entity::Flight).find_average_price_from_to(
          input.first.origin_location_code,
          input.first.destination_location_code
        ).round(2)

        Success(input)
      rescue StandardError
        Failure('Could not retrieve historical average data')
      end

      def historical_lowest(input)
        input = Repository::For.klass(Entity::Flight).find_best_price_from_to(
          input.first.origin_location_code,
          input.first.destination_location_code
        )
        Success(input)
      rescue StandardError
        Failure('Could not retrieve historical lowest data')
      end
    end
  end
end
