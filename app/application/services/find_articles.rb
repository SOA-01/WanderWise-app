# frozen_string_literal: true

require 'dry/transaction'

module WanderWise
  module Service
    # Service to store article data
    class FindArticles
      include Dry::Transaction

      step :find_articles

      private

      def find_articles(input)
        input = articles_from_news_api(input)

        return Failure('Could not find articles.') if input.failure?

        Success(input.value!)
      rescue StandardError
        Failure(error.to_s)
      end

      def articles_from_news_api(input)
        news_api = NYTimesAPI.new
        article_mapper = ArticleMapper.new(news_api)
        article_data = article_mapper.find_articles(input)

        if article_data.empty? || article_data.nil?
          Failure('No articles found for the given criteria.')
        else
          Success(article_data)
        end
      end
    end
  end
end
