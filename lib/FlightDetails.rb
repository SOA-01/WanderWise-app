module WanderWise
    class FlightOffer
      attr_reader :origin, :destination, :departure_date, :price
  
      def initialize(origin:, destination:, departure_date:, price:)
        @origin = origin
        @destination = destination
        @departure_date = departure_date
        @price = price
      end
  
      def to_s
        "Flight from #{origin} to #{destination} on #{departure_date} for $#{price}"
      end
    end
end
  