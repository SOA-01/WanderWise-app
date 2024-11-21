# frozen_string_literal: true

require 'roda'
require 'slim'
require 'figaro'
require 'airports'
require 'securerandom'
require_relative '../infrastructure/amadeus/gateways/amadeus_api'
require_relative '../infrastructure/nytimes/gateways/nytimes_api'
require_relative '../infrastructure/database/repositories/flights'
require 'logger'

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
      @logger ||= Logger.new($stdout) # Logs to standard output (console)
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
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
        view 'home'
      end

      # POST /submit - Handle submitting flight data
      routing.post 'submit' do # rubocop:disable Metrics/BlockLength
        # Step 1: Retrieve flight data from Amadeus API
        amadeus_api = WanderWise::AmadeusAPI.new
        flight_mapper = WanderWise::FlightMapper.new(amadeus_api)
        flight_data = flight_mapper.find_flight(routing.params)
        session[:watching] ||= []
        session[:watching] << { origin: flight_data.first.origin_location_code, destination: flight_data.first.destination_location_code }

        if flight_data.empty? || flight_data.nil?
          flash[:error] = 'No flights found for the given criteria.'
          logger.error 'Error: No flights found for the given criteria.'
          session[:flash] = flash.to_hash
          routing.redirect '/'
        end

        # Step 2: Retrieve country based on destination
        country = Airports.find_by_iata_code(flight_data.first.destination_location_code).country

        if country.nil? || country.empty?
          flash[:error] = 'Unable to find country for the destination location code.'
          logger.error 'Error: Unable to find country for the destination location code.'
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

        # Step 6: Ask AI for opinion on the destination
        gemini_api = WanderWise::GeminiAPI.new
        gemini_mapper = WanderWise::GeminiMapper.new(gemini_api)

        month = routing.params['departureDate'].split('-')[1].to_i
        destination = routing.params['destinationLocationCode']
        origin = routing.params['originLocationCode']
        gemini_answer = gemini_mapper.find_gemini_data("What is your opinion on #{destination} in #{month}?" "Based on historical data, the average price for a flight from #{origin} to #{destination} is $#{historical_average_data}. Does it seem safe based on recent news articles: #{nytimes_articles.to_s}?")

        # Render the results view with all gathered data
        view 'results', locals: {
          flight_data:, country:, nytimes_articles:, gemini_answer:,
          historical_lowest_data:, historical_average_data:
        }
      rescue WanderWise::AmadeusAPI::AmadeusAPIError => e
        flash[:error] = 'Flight data could not be retrieved'
        logger.error "Flash Error: #{flash[:error]} - #{e.message}"
        session[:flash] = flash.to_hash
        routing.redirect '/'  # Do not redirect immediately after setting flash
      rescue WanderWise::NYTimesAPI::Error => e
        flash[:error] = 'News articles could not be retrieved'
        logger.error "Flash Error: #{flash[:error]} - #{e.message}"
        session[:flash] = flash.to_hash
        routing.redirect '/'  # Do not redirect immediately after setting flash
      rescue StandardError => e
        flash[:error] = 'An unexpected error occurred'
        logger.error "Flash Error: #{flash[:error]} - #{e.message}"
        session[:flash] = flash.to_hash
        routing.redirect '/'  # Do not redirect immediately after setting flash
      end
    end
  end
end
