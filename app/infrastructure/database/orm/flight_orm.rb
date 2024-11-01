# frozen_string_literal: true

require 'sequel'

module WanderWise
  module Database
    # Object-Relational Mapper for flights
    class FlightOrm < Sequel::Model(:flights)
      many_to_many :articles,
                   class: 'WanderWise::Database::ArticleOrm',
                   join_table: :flights_articles,
                   left_key: :flight_id,
                   right_key: :article_id
    end
  end
end
