require 'http'
require 'yaml'
require 'json'
require 'date'
require 'fileutils'

module WanderWise
    class NYTimesAPI
        attr_reader :API_KEY
        
        def initialize
        @API_KEY = load_api_credentials['nytimes_api_key']
        end

        def load_api_credentials
        YAML.load_file('../config/secrets.yml')
        end

        def fetch_last_week
        today = DateTime.now
        last_week = today - 7
        last_week.strftime('%Y%m%d')
        end

        def fetch_articles(keyword)
        base_url = 'https://api.nytimes.com/svc/search/v2/articlesearch.json'

        params = {
            'q' => keyword,
            'begin_date' => fetch_last_week,
            'end_date' => DateTime.now.strftime('%Y%m%d'),
            'api-key' => @API_KEY
        }

        response = HTTP.get(base_url, params: params)

        if response.status == 200
            articles = JSON.parse(response.body.to_s)['response']['docs']

            save_articles_to_yaml(articles)

            articles.each do |article|
            puts "Title: #{article.dig('headline', 'main') || 'No title'}"
            puts "Published Date: #{article['pub_date'] || 'No date'}"
            puts "URL: #{article['web_url'] || 'No URL'}"
            puts '-' * 80
            end
        else
            puts "Error: Unable to fetch articles. Status code: #{response.status}"
        end
        end

        def save_articles_to_yaml(articles)
        dir_path = '../spec/fixtures'
        FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

        file_path = File.join(dir_path, 'nytimes-results.yml')

        File.open(file_path, 'w') do |file|
            file.write(articles.to_yaml)
        end

        puts "Articles saved to #{file_path}"
        end
    end
end