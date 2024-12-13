# frozen_string_literal: true

require 'dry/transaction'

module WanderWise
  module Service
    class FindArticles
      include Dry::Transaction

      step :fetch_articles

      def initialize(api_gateway)
        @api_gateway = api_gateway
      end

      private

      def fetch_articles(input)
        response = @api_gateway.fetch_articles(input)

        if response.success?
          Success(response.payload)
        else
          Failure('No articles found for the given criteria.')
        end
      end
    end
  end
end
