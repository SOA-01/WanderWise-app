require 'sequel'

module WanderWise
  module Database
    class NyTimeOrm < Sequel::Model(:nytimes)
      many_to_many :flights,
                   class: 'WanderWise::Database::FlightOrm',
                   join_table: :flights_nytimes,
                   left_key: :nytime_id,
                   right_key: :flight_id
    end
  end
end
