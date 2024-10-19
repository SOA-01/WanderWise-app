# frozen_string_literal: true

require_relative '../gateways/nytimes_api'
require_relative '../entities/nytimes_entity'

module WanderWise
  # Mapper class for transforming raw NY Times article data into NYTimesEntity
  class NYTimesMapper
    def initialize(gateway)
      @gateway = gateway
    end

    # Finds and returns an array of NYTimesEntity objects based on the search keyword
    def find_articles(keyword)
      # Fetch the raw articles data from the API using the gateway
      articles_data = @gateway.fetch_recent_articles(keyword)

      # Map each article to an entity and return the array of NYTimesEntity objects
      articles_data['response']['docs'].map { |article_data| build_entity(article_data) }
    end

    private

    # Converts raw API article data into an NYTimesEntity object
    def build_entity(article_data)
      # Extract relevant attributes from the raw data
      attributes = {
        title: article_data.dig('headline', 'main'),
        published_date: article_data['pub_date'],
        url: article_data['web_url']
      }

      # Return the NYTimesEntity object with the extracted attributes
      NYTimesEntity.new(attributes)
    end
  end
end
