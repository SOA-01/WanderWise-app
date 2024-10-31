# frozen_string_literal: true

require 'sequel'

module WanderWise
  module Database
    # Object-Relational Mapper for articles
    class ArticleOrm < Sequel::Model(:articles)
      many_to_many :flights,
                   class: 'WanderWise::Database::FlightOrm',
                   join_table: :flights_articles,
                   left_key: :article_id,
                   right_key: :flight_id
    end
  end
end
