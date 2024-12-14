# frozen_string_literal: true

require 'dry/transaction'

module WanderWise
  module Service
    # Service to find articles
    class FindArticles
      include Dry::Transaction

      step :fetch_articles

      private

      def fetch_articles(input)
        @api_gateway = WanderWise::Gateway::Api.new(WanderWise::App.config)
        response = @api_gateway.fetch_articles(country: input)

        if response.success?
          Success(response.payload)
        else
          Failure('No articles found for the given criteria.')
        end
      end
    end
  end
end
