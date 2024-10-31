# frozen_string_literal: true

module WanderWise
  module Repository
    class Flights
      def self.find_id(id)
        rebuild_entity Database::FlightOrm.where(id: id).all
      end

      def self.find_date(date)
        rebuild_entity Database::FlightOrm.where(published_date: date).all
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        db_record.map do |record|
          Entity::Flight.new(
            id: record.id,
            origin_location_code: record.origin_location_code,
            destination_location_code: record.destination_location_code,
            departure_date: record.departure_date,
            price: record.price,
            airline: record.airline,
            duration: record.duration,
            departure_time: record.departure_time,
            arrival_time: record.arrival_time
          )
        end
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_flight|
          Flights.rebuild_entity(db_flight)
        end
      end

      def self.create(entity)
        record = Database::FlightOrm.create(
          origin_location_code: entity.origin_location_code,
          destination_location_code: entity.destination_location_code,
          departure_date: entity.departure_date,
          price: entity.price,
          airline: entity.airline,
          duration: entity.duration,
          departure_time: entity.departure_time,
          arrival_time: entity.arrival_time
        )
      end

      def self.create_many(entities)
        entities.map { |entity| create(entity) }
      end

      def self.update(entity)
        Database::FlightOrm.where(id: entity.id).update(
          origin_location_code: entity.origin_location_code,
          destination_location_code: entity.destination_location_code,
          departure_date: entity.departure_date,
          price: entity.price,
          airline: entity.airline,
          duration: entity.duration,
          departure_time: entity.departure_time,
          arrival_time: entity.arrival_time
        )
      end

      def self.delete(id)
        Database::FlightOrm.where(id: id).delete
      end
    end
  end
end