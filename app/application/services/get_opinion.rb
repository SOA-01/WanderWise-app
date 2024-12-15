# frozen_string_literal: true

require 'dry/transaction'

module WanderWise
  module Service
    # Service object to get opinion
    class GetOpinion
      include Dry::Transaction

      step :fetch_opinion

      private

      def fetch_opinion(input)
        @api_gateway = WanderWise::Gateway::Api.new(WanderWise::App.config)
        response = @api_gateway.fetch_opinion(input)

        if response.success?
          Success(response.payload)
        else
          Failure('Could not fetch opinion')
        end
      end
    end
  end
end
