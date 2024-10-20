# frozen_string_literal: true

require 'yaml'
require 'fileutils'

module WanderWise
  # Mapper class for transforming API data into NYTimesEntity
  class NYTimesMapper
    def initialize(gateway)
      @gateway = gateway
    end

    # Find and map articles to entity
    def find_articles(keyword)
      articles_data = @gateway.fetch_recent_articles(keyword)

      # Error handling for bad API responses
      unless articles_data.is_a?(Hash) && articles_data['response'] && articles_data['response']['docs']
        raise "Unexpected response from NYTimes API: #{articles_data.inspect}"
      end

      # Map the articles to entities
      articles_data['response']['docs'].map { |article_data| build_entity(article_data) }
    end

    def save_articles_to_yaml(keyword, file_path)
      articles = find_articles(keyword)
      FileUtils.mkdir_p(File.dirname(file_path)) unless Dir.exist?(File.dirname(file_path))

      File.open(file_path, 'w') do |file|
        file.write(articles.map(&:to_h).to_yaml)
      end

      articles
    end

    private

    def build_entity(article_data)
      NYTimesEntity.new(
        title: article_data.dig('headline', 'main'),
        published_date: article_data['pub_date'],
        url: article_data['web_url']
      )
    end
  end
end
