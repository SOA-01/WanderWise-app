# frozen_string_literal: true

require 'dry/transaction'
require 'airports'

module WanderWise
  module Service
    # Service to find a country
    class FindCountry
      include Dry::Transaction

      step :find_country

      private

      def find_country(input)
        country = Airports.find_by_iata_code(input[:destinationLocationCode]).country

        Success(country)
      rescue StandardError
        Failure('Unable to find country for the destination location code.')
      end
    end
  end
end
