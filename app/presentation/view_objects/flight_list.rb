# frozen_string_literal: true

module Views
  # View for a list of entities of flights
  class FlightList
    def initialize(flights)
      @flights = flights.is_a?(String) ? JSON.parse(flights) : flights
    end

    def each(&block)
      @flights.each(&block)
    end

    def any?
      @flights.any?
    end
  end
end
