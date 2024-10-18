# frozen_string_literal: true

module WanderWise
  # Handles all API requests to the NY Times API
  class NYTimesAPI
    # Initialize the API client
    def initialize
      @secrets = YAML.load_file('./config/secrets.yml')
      @api_key = @secrets['nytimes_api_key']
    end

    def fetch_recent_articles(keyword)
      today = DateTime.now
      one_week_ago = (today - 7).strftime('%Y%m%d')
      base_url = 'https://api.nytimes.com/svc/search/v2/articlesearch.json'

      params = {
        'q' => keyword,
        'begin_date' => one_week_ago,
        'end_date' => today.strftime('%Y%m%d'),
        'api-key' => @api_key
      }

      fetch_articles(base_url, params)
    end

    private

    # Generate last week's date in the format required by the API

    def fetch_articles(base_url, params)
      response = HTTP.get(base_url, params:)
      status_code = response.status

      if status_code == 200
        articles = JSON.parse(response.body.to_s)['response']['docs']
        articles.each do |article|
          puts "Title: #{article.dig('headline', 'main') || 'No title'}"
          puts "Published Date: #{article['pub_date'] || 'No date'}"
          puts "URL: #{article['web_url'] || 'No URL'}"
          puts '-' * 80
        end
      else
        puts "Error: Unable to fetch articles. Status code: #{status_code}"
      end
    end
  end
end
