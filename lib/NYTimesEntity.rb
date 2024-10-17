require_relative 'NYTimesAPI'

module WanderWise
    # Initialize the API client

  class NYTimesEntity
    @api = nil
    @default_keyword = 'Taiwan'
    
    def initialize
        @api = NYTimesAPI.new
    end

    def getArticles(keyword)
      # Get the articles
        @api.fetch_recent_articles(keyword)
    end

    def save_articles_to_yaml
        articles = getArticles(@default_keyword)
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

