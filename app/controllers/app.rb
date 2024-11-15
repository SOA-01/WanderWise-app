# frozen_string_literal: true

require 'roda'
require 'slim'
require 'figaro'
require 'airports'
require 'securerandom'
require_relative '../infrastructure/amadeus/gateways/amadeus_api'
require_relative '../infrastructure/nytimes/gateways/nytimes_api'
require_relative '../infrastructure/database/repositories/flights'
require 'logger'  # Add this line to require Logger

module WanderWise
  # Main application class for WanderWise
  class App < Roda
    plugin :flash
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :halt
    plugin :sessions, secret: ENV['SESSION_SECRET']

    # Create a logger instance (you can change the log file path as needed)
    def logger
      @logger ||= Logger.new(STDOUT)  # Logs to standard output (console)
    end

    route do |routing|
      routing.assets

      # Example of setting session data
      routing.get 'set_session' do
        session[:watching] = 'Some value'
        'Session data set!'
      end

      # Example of accessing session data
      routing.get 'show_session' do
        session_data = session[:watching] || 'No data in session'
        "Session data: #{session_data}"
      end

      # GET / request
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
        begin
          # Step 1: Retrieve flight data from Amadeus API
          amadeus_api = WanderWise::AmadeusAPI.new
          flight_mapper = WanderWise::FlightMapper.new(amadeus_api)
          flight_data = flight_mapper.find_flight(routing.params)
          session[:watching] ||= []
          session[:watching] << { origin: flight_data.first.origin_location_code, destination: flight_data.first.destination_location_code }


          if flight_data.empty? || flight_data.nil?
            flash[:error] = 'No flights found for the given criteria.'
            logger.error "Error: No flights found for the given criteria."
            puts session.inspect
            session[:flash] = flash.to_hash
            routing.redirect '/'
          end

          # Step 2: Retrieve country based on destination
          country = Airports.find_by_iata_code(flight_data.first.destination_location_code).country
          if country.nil? || country.empty?
            flash[:error] = 'Unable to find country for the destination location code.'
            logger.error "Error: Unable to find country for the destination location code."
            puts session.inspect
            session[:flash] = flash.to_hash
            routing.redirect '/'
          end

          # Step 3: Store flight data in DB
          Repository::For.klass(Entity::Flight).create_many(flight_data)

          # Step 4: Retrieve historical flight price data
          historical_lowest_data = Repository::For.klass(Entity::Flight)
                                                  .find_best_price_from_to(
                                                    flight_data.first.origin_location_code,
                                                    flight_data.first.destination_location_code
                                                  )
          historical_average_data = Repository::For.klass(Entity::Flight)
                                                   .find_average_price_from_to(
                                                     flight_data.first.origin_location_code,
                                                     flight_data.first.destination_location_code
                                                   ).round(2)

          # Step 5: Fetch related articles from NY Times
          nytimes_api = WanderWise::NYTimesAPI.new
          article_mapper = WanderWise::ArticleMapper.new(nytimes_api)
          nytimes_articles = article_mapper.find_articles(country)
          # Render the results view with all gathered data
          view 'results', locals: {
            flight_data:, country:, nytimes_articles:,
            historical_lowest_data:, historical_average_data:
          }

        rescue WanderWise::AmadeusAPI::AmadeusAPIError => e
          flash[:error] = "Flight data could not be retrieved"
          logger.error "Flash Error: #{flash[:error]} - #{e.message}"
          puts session.inspect
          session[:flash] = flash.to_hash
          routing.redirect '/'  # Do not redirect immediately after setting flash

        rescue WanderWise::NYTimesAPI::Error => e
          flash[:error] = "News articles could not be retrieved"
          logger.error "Flash Error: #{flash[:error]} - #{e.message}"
          puts session.inspect
          session[:flash] = flash.to_hash
          routing.redirect '/'  # Do not redirect immediately after setting flash

        rescue StandardError => e
          flash[:error] = "An unexpected error occurred"
          logger.error "Flash Error: #{flash[:error]} - #{e.message}"
          puts session.inspect
          session[:flash] = flash.to_hash
          routing.redirect '/'  # Do not redirect immediately after setting flash
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
