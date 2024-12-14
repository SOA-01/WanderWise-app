# frozen_string_literal: true

require 'roda'
require 'slim'
require 'figaro'
require 'securerandom'
require_relative '../forms/new_flight'
require 'logger'

module WanderWise
  # Main application class for WanderWise
  class App < Roda
    plugin :flash
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
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
        # Get cookie viewers from session
        # session[:watching] ||= []

        view 'home'
      end

      # POST /submit - Handle submitting flight data
      routing.post 'submit' do # rubocop:disable Metrics/BlockLength
        # Step 0: Validate form data
        request = WanderWise::Forms::NewFlight.new.call(routing.params)
        logger.debug "Params received: #{routing.params}"
        if request.failure?
          request.errors.each do |error|
            session[:flash] = { error: error.message }
          end
          logger.error "Form errors: #{request.errors.to_h}"
          routing.redirect '/'
        end

        # Step 1: Find flights
        flight_made = Service::AddFlights.new.call(request.to_h)

        if flight_made.failure?
          session[:flash] = { error: flight_made.failure }
          routing.redirect '/'
        end

        flight_data = flight_made.value!
        retrieved_flights = Views::FlightList.new(flight_data)

        # Step 2: Find the destination country
        country = Service::FindCountry.new.call(request.to_h)

        if country.failure?
          session[:flash] = { error: country.failure }
          routing.redirect '/'
        end

        country = country.value!
        destination_country = Views::Country.new(country)

        # Step 4: Retrieve historical flight price data
        analyze_flights = Service::AnalyzeFlights.new.call(request.to_h)

        if analyze_flights.failure?
          session[]
          routing.redirect '/'
        end

        parsed_analyze_flights = JSON.parse(analyze_flights.value!)
        historical_flight_data = Views::HistoricalFlightData.new(
          parsed_analyze_flights['historical_average_data'],
          parsed_analyze_flights['historical_lowest_data']
        )

        # Step 5: Retrieve news articles about the destination
        article_made = Service::FindArticles.new.call(country)

        if article_made.failure?
          session[:flash] = { error: article_made.failure }
          routing.redirect '/'
        end

        nytimes_articles = article_made.value!
        retrieved_articles = Views::ArticleList.new(nytimes_articles)

        month = routing.params['departureDate'].split('-')[1].to_i
        origin = routing.params['originLocationCode']

        details = {
          month: month,
          destination: country,
          origin: origin,
          historical_average_data: parsed_analyze_flights['historical_average_data'],
          nytimes_articles: nytimes_articles
        }

        opinion_made = Service::GetOpinion.new.call(details)

        if opinion_made.failure?
          session[:flash] = { error: opinion_made.failure }
          gemini_data = 'No opinion available'
        else
          gemini_data = opinion_made.value!
        end

        gemini_answer = Views::Opinion.new(gemini_data)

        view 'results', locals: {
          flight_data: retrieved_flights,
          country: destination_country,
          nytimes_articles: retrieved_articles,
          gemini_answer: gemini_answer,
          historical_data: historical_flight_data
        }
      rescue StandardError => e
        flash[:error] = 'An unexpected error occurred'
        logger.error "Flash Error: #{flash[:error]} - #{e.message}"
        session[:flash] = flash.to_hash
        routing.redirect '/' # Do not redirect immediately after setting flash
      end
    end
  end
end
