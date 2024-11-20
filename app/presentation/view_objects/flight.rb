# frozen_string_literal: true

module Views
  # View for a single entity of flights
  class Flight
    def initialize(flight)
      @flight = flight
    end

    def entity
      @flight
    end

    def id
      @flight.id
    end

    def origin_location_code
      @flight.origin_location_code
    end

    def destination_location_code
      @flight.destination_location_code
    end

    def departure_date
      @flight.departure_date
    end

    def price
      @flight.price
    end

    def airline
      @flight.airline
    end

    def duration
      @flight.duration
    end

    def departure_time
      @flight.departure_time
    end

    def arrival_time
      @flight.arrival_time
    end
  end
end
