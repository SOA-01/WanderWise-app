

module WanderWise
    class NYTimesAPI
        def initialize
            @secrets = load_api_credentials
            @api_key = @secrets['nytimes_api_key']
        end

        def load_api_credentials
            YAML.load_file('./config/secrets.yml')
        end

        private def get_last_week
            today = DateTime.now
            last_week = today - 7
            last_week.strftime('%Y%m%d')
        end
    
        def fetch_recent_articles(keyword)
            base_url = 'https://api.nytimes.com/svc/search/v2/articlesearch.json'
          
            params = {
              'q' => keyword,
              'begin_date' => get_last_week,
              'end_date' => DateTime.now.strftime('%Y%m%d'),
              'api-key' => @api_key
            }

            fetch_articles(base_url, params)
            
        end

        private def fetch_articles(base_url, params) 
        
            response = HTTP.get(base_url, params: params)
          
            if response.status == 200
              articles = JSON.parse(response.body.to_s)['response']['docs']
          
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
    end
end