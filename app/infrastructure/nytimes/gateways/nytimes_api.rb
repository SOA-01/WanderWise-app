# frozen_string_literal: true

require 'http'
require 'yaml'
require 'json'
require 'date'
require_relative '../../../models/entities/article'

module WanderWise
  # Gateway to NY Times API for recent articles
  class NYTimesAPI
    def initialize
      environment = ENV['RACK_ENV']
      secrets = YAML.load_file('./config/secrets.yml')
      @secrets = secrets[environment]
      @api_key = @secrets['nytimes_api_key']
      @base_url = 'https://api.nytimes.com/svc/search/v2/articlesearch.json'

      # Create a fixture file for the API response if it doesn't exist
      save_to_fixtures unless File.exist?('./spec/fixtures/nytimes-api-results.yml')
    end

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

      # Return raw parsed JSON as a Ruby hash
      fetch_articles(params)
    end

    def save_to_fixtures
      articles = fetch_recent_articles('travel')

      File.open('./spec/fixtures/nytimes-api-results.yml', 'w') { |file| file.write(articles.to_yaml) }
    end

    # Perform the API call and return the JSON response as a Ruby hash
    def fetch_articles(params)
      response = HTTP.get(@base_url, params:)
      response_body = response.body.to_s.force_encoding('UTF-8')
      JSON.parse(response_body)
    end
  end
end
