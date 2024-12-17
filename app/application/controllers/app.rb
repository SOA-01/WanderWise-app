# frozen_string_literal: true

require 'roda'
require 'slim'
require 'figaro'
require 'securerandom'
require_relative '../forms/new_flight'
require 'logger'
require 'concurrent'

module WanderWise
  # Main application class for WanderWise
  class App < Roda # rubocop:disable Metrics/ClassLength
    plugin :flash
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :halt
    plugin :sessions, secret: ENV['SESSION_SECRET']

    def logger
      @logger ||= Logger.new($stdout)
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      routing.assets

      routing.get 'set_session' do
        session[:watching] = 'Some value'
        'Session data set!'
      end

      routing.get 'show_session' do
        session_data = session[:watching] || 'No data in session'
        "Session data: #{session_data}"
      end

      routing.root do
        view 'home'
      end

      routing.post 'submit' do # rubocop:disable Metrics/BlockLength
        logger.info 'Starting form validation'
        request = WanderWise::Forms::NewFlight.new.call(routing.params)
        if request.failure?
          session[:flash] = { error: request.errors.to_h.values.join(', ') }
          logger.error "Form validation failed: #{request.errors.to_h}"
          routing.redirect '/'
        end

        request_data = request.to_h
        logger.info "Form validation successful: #{request_data}"

        # Step 1: Concurrently load flights, country, and analysis data
        logger.info 'Starting concurrent promises'
        flights_promise = Concurrent::Promise.execute do
          logger.info 'Loading flights...'
          result = Service::AddFlights.new.call(request_data)
          logger.info 'Flights loaded'
          result
        end

        country_promise = Concurrent::Promise.execute do
          logger.info 'Finding country...'
          result = Service::FindCountry.new.call(request_data)
          logger.info "Country found: #{result}"
          result
        end

        analyze_flights_promise = Concurrent::Promise.execute do
          logger.info 'Analyzing flights...'
          result = Service::AnalyzeFlights.new.call(request_data)
          logger.info "Flight analysis complete: #{result}"
          result
        end

        # Fetch articles based on country result
        articles_promise = country_promise.then do |country|
          if country.success?
            logger.info "Country found successfully: #{country.value!}. Fetching articles..."
            Service::FindArticles.new.call(country.value!)
          else
            logger.error "Country failed: #{country.failure}"
            Concurrent::Promise.reject(country.failure)
          end
        end

        # Create ProgressPage instance
        logger.info 'Initializing ProgressPage'
        progress_page = Views::ProgressPage.new(
          OpenStruct.new(API_HOST: ENV['API_HOST']), 
          flights_promise
        )

        # Generate opinion based on results
        opinion_promise = Concurrent::Promise.zip(country_promise, analyze_flights_promise,
                                                  articles_promise).then do |(country, analyze_flights, articles)|
          if country.success? && analyze_flights.success? && articles.success?
            logger.info 'Country, flight analysis, and articles fetched successfully. Generating opinion...'
            details = {
              month: routing.params['departureDate'].split('-')[1].to_i,
              destination: country.value!,
              origin: routing.params['originLocationCode'],
              historical_average_data: JSON.parse(analyze_flights.value!)['historical_average_data'],
              articles: articles.value!
            }
            result = Service::GetOpinion.new.call(details)
            if result.success?
              result.value!
            else
              logger.error "Opinion generation failed: #{result.failure}"
              'No opinion available' # Fallback
            end
          else
            logger.error "Failed to generate opinion: country - #{country.failure}, analyze_flights - #{analyze_flights.failure}, articles - #{articles.failure}" # rubocop:disable Layout/LineLength
            'No opinion available' # Fallback
          end
        end

        logger.info 'Waiting for all promises to resolve'
        Concurrent::Promise.zip(
          flights_promise, country_promise, analyze_flights_promise, articles_promise, opinion_promise
        ).value!

        # Collect results and handle failures
        logger.info 'Collecting results'
        flight_data = flights_promise.value!
        country_result = country_promise.value!
        analyze_flights_result = analyze_flights_promise.value!
        articles_result = articles_promise.value!
        opinion_result = opinion_promise.value! # No `.value!` if it's already a string fallback

        logger.info 'Results collected'

        errors = []
        errors << flight_data.failure if flight_data.failure?
        errors << country_result.failure if country_result.failure?
        errors << analyze_flights_result.failure if analyze_flights_result.failure?
        errors << articles_result.failure if articles_result.failure?

        # NOTE: Do not add opinion errors, as it already has a fallback
        unless errors.empty?
          logger.error "Errors encountered: #{errors.join(', ')}"
          session[:flash] = { error: errors.join(', ') }
          routing.redirect '/'
        end

        # Prepare data for rendering
        logger.info 'Preparing data for rendering'
        retrieved_flights = Views::FlightList.new(flight_data.value!)
        destination_country = Views::Country.new(country_result.value!)
        historical_flight_data = Views::HistoricalFlightData.new(
          JSON.parse(analyze_flights_result.value!)['historical_average_data'],
          JSON.parse(analyze_flights_result.value!)['historical_lowest_data']
        )
        retrieved_articles = Views::ArticleList.new(articles_result.value!)
        gemini_answer = Views::Opinion.new(opinion_result) # Use the fallback directly

        # Render results
        logger.info 'Rendering results view'
        view 'results', locals: {
          flight_data: retrieved_flights,
          country: destination_country,
          nytimes_articles: retrieved_articles,
          gemini_answer: gemini_answer,
          historical_data: historical_flight_data,
          progress_channel_id: progress_page.channel_id,
          faye_js_url: progress_page.faye_javascript_url
        }
      rescue StandardError => e
        logger.error "Unexpected error: #{e.message}"
        logger.error e.backtrace.join("\n") # Log the full backtrace
        flash[:error] = 'An unexpected error occurred'
        session[:flash] = flash.to_hash
        routing.redirect '/'
      end
    end
  end
end
