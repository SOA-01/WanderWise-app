# frozen_string_literal: true

require 'dry-validation'
require 'airports'

module WanderWise
  module Forms
    # Form validation for new flight data
    class NewFlight < Dry::Validation::Contract
      params do
        required(:originLocationCode).filled(:string)
        required(:destinationLocationCode).filled(:string)
        required(:departureDate).filled(:string)
        required(:adults).filled(:integer)
      end

      rule(:departureDate) do
        key.failure('Must be in the format YYYY-MM-DD') unless value.match?(/^\d{4}-\d{2}-\d{2}$/)
        key.failure('Must be a future date') if value < Date.today.to_s
      end

      rule(:adults) do
        key.failure('Must be at least one adult') if value < 1
      end

      rule(:originLocationCode) do
        key.failure('Must be a valid origin airport code') unless Airports.find_by_iata_code(value)
      end

      rule(:destinationLocationCode) do
        key.failure('Must be a valid destination airport code') unless Airports.find_by_iata_code(value)
      end
    end
  end
end
