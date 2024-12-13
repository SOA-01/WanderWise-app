# frozen_string_literal: true

require 'http'
require 'json'

module WanderWise
  module Gateway
    # Infrastructure to call WanderWise Web API
    class Api
      def initialize(config)
        @config = config
        @request = Request.new(@config)
      end

      def alive?
        @request.get_root.success?
      end

      def fetch_flights(query_params)
        @request.get('flights', query_params)
      end

      def fetch_articles(query_params)
        @request.get('articles', query_params)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_root = "#{config.API_HOST}/api/v1"
        end

        def get(endpoint, params = {})
          call_api('get', [endpoint], params)
        end

        private

        def call_api(method, resources = [], params = {})
          url = [@api_root, *resources].join('/') + params_to_query(params)
          HTTP.headers(accept: 'application/json').send(method, url)
            .then { |http_response| Response.new(http_response) }
        rescue StandardError => e
          raise "API Request failed: #{e.message}"
        end

        def params_to_query(params)
          return '' if params.empty?

          '?' + URI.encode_www_form(params)
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        SUCCESS_CODES = (200..299).freeze

        def success?
          SUCCESS_CODES.include?(code)
        end

        def message
          parsed_body['message']
        end

        def payload
          parsed_body
        end

        private

        def parsed_body
          JSON.parse(body.to_s)
        rescue JSON::ParserError
          raise 'Invalid JSON response'
        end
      end
    end
  end
end
