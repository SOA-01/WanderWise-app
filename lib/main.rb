require 'http'
require 'yaml'
require 'json'
require_relative 'FlightsEntity'


def fetch_resource(url, params = {})
  response = HTTP.get(url, params: params)
  JSON.parse(response.body.to_s)
end

def load_api_credentials
  YAML.load_file('./config/secrets.yml')
end

def authenticate(secrets)
  auth_url = 'https://test.api.amadeus.com/v1/security/oauth2/token'
  response = HTTP.post(auth_url, form: {
                         grant_type: 'client_credentials',
                         client_id: secrets['amadeus_client_id'],
                         client_secret: secrets['amadeus_client_secret']
                       })
  JSON.parse(response.body.to_s)
end

def fetch_response(access_token, params)
  flight_offers_url = 'https://test.api.amadeus.com/v2/shopping/flight-offers'

  response = HTTP.auth("Bearer #{access_token}")
                 .get(flight_offers_url, params: params)

  JSON.parse(response.body.to_s)
end

def fetch_flight_offers(origin, destination, date, adults)
  secrets = load_api_credentials
  auth_data = authenticate(secrets)
  access_token = auth_data['access_token']

  params = {
    originLocationCode: origin,
    destinationLocationCode: destination,
    departureDate: date,
    adults: adults
  }

  fetch_response(access_token, params)
end

# flight_offers = fetch_flight_offers('TPE', 'LAX', '2024-10-07', 1)

# File.open('../spec/fixtures/flight-offers-results.yml', 'w') do |file|
#   file.write(flight_offers.to_yaml)
# end

# puts 'Flight offers saved to spec/fixtures/flight-offers-results.yml'

flightEntity = WanderWise::FlightsEntity.new
flightEntity.yamlFlightInfo


# # ----- 2. NY API -----

# secrets = load_api_credentials
# API_KEY = secrets['nytimes_api_key']

# def fetch_last_week
#   today = DateTime.now
#   last_week = today - 7
#   last_week.strftime('%Y%m%d')
# end

# def fetch_articles(keyword)
#   base_url = 'https://api.nytimes.com/svc/search/v2/articlesearch.json'

#   params = {
#     'q' => keyword,
#     'begin_date' => fetch_last_week,
#     'end_date' => DateTime.now.strftime('%Y%m%d'),
#     'api-key' => API_KEY
#   }

#   response = HTTP.get(base_url, params: params)

#   if response.status == 200
#     articles = JSON.parse(response.body.to_s)['response']['docs']

#     save_articles_to_yaml(articles)

#     articles.each do |article|
#       puts "Title: #{article.dig('headline', 'main') || 'No title'}"
#       puts "Published Date: #{article['pub_date'] || 'No date'}"
#       puts "URL: #{article['web_url'] || 'No URL'}"
#       puts '-' * 80
#     end
#   else
#     puts "Error: Unable to fetch articles. Status code: #{response.status}"
#   end
# end

# def save_articles_to_yaml(articles)
#   dir_path = '../spec/fixtures'
#   FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

#   file_path = File.join(dir_path, 'nytimes-results.yml')

#   File.open(file_path, 'w') do |file|
#     file.write(articles.to_yaml)
#   end

#   puts "Articles saved to #{file_path}"
# end

# # Example usage
# keyword = 'Taiwan' # Change the keyword to what you want
# fetch_articles(keyword)
