# frozen_string_literal: true

require_relative 'NYTimesAPI'

module WanderWise
  # Initialize the API client

  # Handles logic outside the API calls
  class NYTimesEntity
    @api = nil

    def initialize
      @api = NYTimesAPI.new
    end

    def get_articles(keyword)
      # Get the articles
      @api.fetch_recent_articles(keyword)
    end

    def save_articles_to_yaml
      articles = get_articles('Taiwan')
      dir_path = './spec/fixtures'
      FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

      file_path = File.join(dir_path, 'nytimes-results.yml')

      File.open(file_path, 'w') do |file|
        file.write(articles.to_yaml)
      end

      puts "Articles saved to #{file_path}"
    end
  end
end
