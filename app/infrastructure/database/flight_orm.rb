require 'sequel'

module WanderWise
  module Database
    class FlightOrm < Sequel::Model(:flights)
     many_to_many :nytimes,
                   class: 'WanderWise::Database::NyTimeOrm',
                   join_table: :flights_nytimes,
                   left_key: :flight_id,
                   right_key: :nytime_id
    end
  end
end
