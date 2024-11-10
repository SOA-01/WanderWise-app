require 'roda'
require 'slim'
require 'figaro'
require 'airports'
require 'securerandom'
require_relative '../infrastructure/amadeus/gateways/amadeus_api'
require_relative '../infrastructure/nytimes/gateways/nytimes_api'
require_relative '../infrastructure/database/repositories/flights'

module WanderWise
  class App < Roda
    ENV['SESSION_SECRET'] ||= SecureRandom.hex(128) 
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :halt
    plugin :flash
    plugin :sessions, secret: ENV['SESSION_SECRET']

    route do |routing|
      routing.assets

      # Root route
      routing.root do
        # Initialize session data for form values if not already set
        session[:originLocationCode] ||= 'TPE'
        session[:destinationLocationCode] ||= 'LAX'
        session[:departureDate] ||= '2024-11-05'
        session[:adults] ||= 1

        view 'home'
      end

      # POST /submit - Handle submitting flight data
      routing.post 'submit' do
        # Step 1: Save form data to session for re-rendering in case of error
        session[:originLocationCode] = routing.params['originLocationCode']
        session[:destinationLocationCode] = routing.params['destinationLocationCode']
        session[:departureDate] = routing.params['departureDate']
        session[:adults] = routing.params['adults']

        # Step 2: Initialize APIs and Mappers
        begin
          amadeus_api = WanderWise::AmadeusAPI.new
          flight_mapper = WanderWise::FlightMapper.new(amadeus_api)
          nytimes_api = WanderWise::NYTimesAPI.new
          article_mapper = WanderWise::ArticleMapper.new(nytimes_api)
        rescue StandardError => error
          flash[:error] = "Error initializing services: #{error.message}"
          routing.redirect '/'
        end

        # Step 3: Get flight data from Amadeus API
        flight_data = nil
        begin
          flight_data = flight_mapper.find_flight(routing.params)
          unless flight_data&.any?
            flash[:notice] = 'No flights found for the given parameters.'
            routing.redirect '/'
          end
        rescue StandardError => error
          flash[:error] = "Error retrieving flight data: #{error.message}"
          routing.redirect '/'
        end

        # Step 4: Get destination country
        country = nil
        begin
          destination_code = flight_data.first.destination_location_code
          country = Airports.find_by_iata_code(destination_code)&.country
          if country.nil?
            flash[:notice] = 'Country information not found for the destination.'
            routing.redirect '/'
          end
        rescue StandardError => error
          flash[:error] = "Error retrieving country information: #{error.message}"
          routing.redirect '/'
        end

        # Step 5: Store flight data in the database
        begin
          Repository::For.klass(Entity::Flight).create_many(flight_data)
        rescue StandardError => error
          flash[:error] = "Error saving flight data: #{error.message}"
          routing.redirect '/'
        end

        # Step 6: Get historical pricing data
        begin
          origin_code = flight_data.first.origin_location_code
          lowest_data = Repository::For.klass(Entity::Flight).find_best_price_from_to(origin_code, destination_code)
          average_data = Repository::For.klass(Entity::Flight).find_average_price_from_to(origin_code, destination_code).round(2)
        rescue StandardError => error
          flash[:notice] = 'Historical pricing data unavailable.'
          lowest_data, average_data = nil, nil
        end

        # Step 7: Get news articles from NY Times API
        nytimes_articles = []
        begin
          nytimes_articles = article_mapper.find_articles(country)
        rescue StandardError => error
          flash[:notice] = 'News articles could not be retrieved at this time.'
        end

        # Step 8: Display results
        view 'results', locals: {
          flight_data: flight_data,
          country: country,
          nytimes_articles: nytimes_articles,
          historical_lowest_data: lowest_data,
          historical_average_data: average_data
        }
      end
    end
  end
end
