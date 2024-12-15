# frozen_string_literal: true

require 'http'
require 'json'
require 'uri'

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
        @request.post('flights', query_params)
      end

      def fetch_articles(query_params)
        @request.post('articles', query_params)
      end

      def analyze_flight(flight_data)
        @request.post('analyze', flight_data)
      end

      def fetch_opinion(query_params)
        @request.get('opinion', query_params)
      end

      # HTTP request transmitter
      class Request
        def initialize(config)
          @api_host = config.API_HOST
          @api_root = "#{config.API_HOST}/api/v1"
        end

        def get(endpoint, params = {})
          call_api('get', [endpoint], params)
        end

        def post(endpoint, params = {})
          call_api('post', [endpoint], params)
        end

        private

        def call_api(method, resources = [], params = {})
          api_path = resources.empty? ? @api_host : @api_root
          url = [api_path, resources].flatten.join('/') + params_to_query(params)
          HTTP.headers('Accept' => 'application/json').send(method, url)
              .then { |http_response| Response.new(http_response) }
        rescue StandardError
          raise "Invalid URL request: #{url}"
        end

        def params_str(params)
          params.map { |key, value| "#{key}=#{value}" }.join('&')
                .then { |str| str ? "?#{str}" : '' }
        end

        def params_to_query(params)
          return '' if params.empty?

          "?#{URI.encode_www_form(params)}"
        end
      end

      # Decorates HTTP responses with success/error
      class Response < SimpleDelegator
        SUCCESS_CODES = (200..299)

        def success?
          code.between?(SUCCESS_CODES.first, SUCCESS_CODES.last)
        end

        def failure?
          !success?
        end

        def ok?
          code == 200
        end

        def added?
          code == 201
        end

        def processing?
          code == 202
        end

        def message
          JSON.parse(payload)['message']
        end

        def payload
          body.to_s
        end
      end
    end
  end
end
