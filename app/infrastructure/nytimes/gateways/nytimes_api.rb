# frozen_string_literal: true

require 'http'
require 'yaml'
require 'json'
require 'date'
require_relative '../../../domain/entities/article'

module WanderWise
  # Gateway to NY Times API for recent articles
  class NYTimesAPI
    class Error < StandardError; end

    def initialize # rubocop:disable Metrics/MethodLength
      # Set the environment from RACK_ENV or default to development
      environment = ENV['RACK_ENV'] || 'development'

      # Load secrets from environment variables for production or from secrets.yml for development
      if environment == 'production'
        # In production, use environment variables for API keys
        @api_key = ENV['nytimes_api_key']
        raise 'NYTIMES_API_KEY environment variable is missing!' if @api_key.nil?
      else
        # In non-production environments, load from secrets.yml
        environment = ENV['RACK_ENV']
        secrets = YAML.load_file('./config/secrets.yml')
        @secrets = secrets[environment]
        @api_key = @secrets['nytimes_api_key']
      end
      @base_url = 'https://api.nytimes.com/svc/search/v2/articlesearch.json'
      save_to_fixtures unless File.exist?('./spec/fixtures/nytimes-api-results.yml') || environment == 'production'
    end

    #     def initialize
    #       environment = ENV['RACK_ENV']
    #       secrets = YAML.load_file('./config/secrets.yml')
    #       @secrets = secrets[environment]
    #       @api_key = @secrets['nytimes_api_key']

    # Create a fixture file for the API response if it doesn't exist in development/test

    # Fetch recent articles based on the keyword
    def fetch_recent_articles(keyword)
      today = DateTime.now
      one_week_ago = (today - 7).strftime('%Y%m%d')

      params = {
        'q' => keyword,
        'begin_date' => one_week_ago,
        'end_date' => today.strftime('%Y%m%d'),
        'api-key' => @api_key
      }

      # Return raw parsed JSON as a hash
      fetch_articles(params)
    end

    def save_to_fixtures
      articles = fetch_recent_articles('travel')

      File.open('./spec/fixtures/nytimes-api-results.yml', 'w') { |file| file.write(articles.to_yaml) }
    end

    # Perform the API call and return the JSON response as a Ruby hash
    def fetch_articles(params) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      response = HTTP.get(@base_url, params:)
      raise Error, "Failed to fetch articles from NY Times: #{response.status}" if response.status != 200

      response_body = response.body.to_s.force_encoding('UTF-8')
      begin
        parsed_response = JSON.parse(response_body)
        parsed_response['response'] && parsed_response['response']['docs'] ? parsed_response : { 'response' => { 'docs' => [] } }
      rescue JSON::ParserError => e
        raise Error, "Error parsing NY Times response: #{e.message}"
      end
    rescue JSON::ParserError => e
      raise Error, "Error parsing NY Times response: #{e.message}"
    rescue StandardError => e
      raise Error, "An unexpected error occurred: #{e.message}"
    end
  end
end
