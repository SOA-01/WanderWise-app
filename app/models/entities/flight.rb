# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

# Define custom types for the Flight entity
module Types
  include Dry.Types()
end

module WanderWise
  # Domain entity for Flight data
  class Flight < Dry::Struct
    attribute :id, Types::Integer.optional.default(nil)
    attribute :origin_location_code, Types::String
    attribute :destination_location_code, Types::String
    attribute :departure_date, Types::String
    attribute :price, Types::Float.optional
    attribute :airline, Types::String.optional
    attribute :duration, Types::String.optional
    attribute :departure_time, Types::String.optional
    attribute :arrival_time, Types::String.optional

    def flight_summary
      "Flight from #{origin_location_code} to #{destination_location_code} on #{departure_date} for #{adults} adult(s)."
    end
  end
end
