require 'http'
require 'yaml'
require 'json'
require 'date'
require 'fileutils'
require_relative 'AmadeusAPI'
require_relative 'NYTimesAPI'
require_relative 'FlightDetails'
require_relative 'Article'

module WanderWise
  class APIHandler
    attr_reader :secrets
  
    def initialize
      @secrets = load_api_credentials
    end
  
    # Load the API credentials from secrets.yml
    def load_api_credentials
      YAML.load_file('../config/secrets.yml')
    end
  
    # Fetch flight offers from the Amadeus API and map them to FlightOffer entities
    def fetch_flight_offers(origin, destination, date, adults)
      auth_data = authenticate_amadeus
      access_token = auth_data['access_token']
      params = {
        originLocationCode: origin,
        destinationLocationCode: destination,
        departureDate: date,
        adults: adults
      }
  
      response = HTTP.auth("Bearer #{access_token}")
                     .get('https://test.api.amadeus.com/v2/shopping/flight-offers', params: params)
  
      flight_offers = JSON.parse(response.body.to_s)['data']
      flight_offers.map do |offer|
        FlightOffer.new(
          origin: offer['itineraries'][0]['segments'][0]['departure']['iataCode'],
          destination: offer['itineraries'][0]['segments'][0]['arrival']['iataCode'],
          departure_date: offer['itineraries'][0]['segments'][0]['departure']['at'],
          price: offer['price']['total']
        )
      end
    end
  
    # Fetch articles from the NY Times API and map them to Article entities
    def fetch_articles(keyword)
      params = {
        'q' => keyword,
        'begin_date' => (Date.today - 7).strftime('%Y%m%d'),
        'end_date' => Date.today.strftime('%Y%m%d'),
        'api-key' => secrets['NYTimesAPI_key']
      }
  
      response = HTTP.get('https://api.nytimes.com/svc/search/v2/articlesearch.json', params: params)
  
      articles = JSON.parse(response.body.to_s)['response']['docs']
      articles.map do |article|
        Article.new(
          title: article['headline']['main'],
          published_date: article['pub_date'],
          url: article['web_url']
        )
      end
    end
  
    # Authenticate with the Amadeus API
    private def authenticate_amadeus
      auth_url = 'https://test.api.amadeus.com/v1/security/oauth2/token'
      response = HTTP.post(auth_url, form: {
        grant_type: 'client_credentials',
        client_id: secrets['amadeus_client_id'],
        client_secret: secrets['amadeus_client_secret']
      })
      JSON.parse(response.body.to_s)
    end
  end
end