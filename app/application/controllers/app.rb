# frozen_string_literal: true

require 'roda'
require 'slim'
require 'figaro'
require 'securerandom'
require_relative '../forms/new_flight'
require 'logger'
require 'concurrent'
require 'redis'

module WanderWise
  # Main application class for WanderWise
  class App < Roda # rubocop:disable Metrics/ClassLength
    plugin :flash
    plugin :render, engine: 'slim', views: 'app/presentation/views_html'
    plugin :assets, css: 'style.css', path: 'app/presentation/assets'
    plugin :assets, js: 'custom.js', path: 'app/presentation/assets'
    plugin :halt
    plugin :sessions, secret: ENV['SESSION_SECRET'], key: 'wanderwise.session', cookie_options: { secure: true, httponly: true, same_site: :none }

    def logger
      @logger ||= Logger.new($stdout)
    end

    def redis
      @redis ||= Redis.new(url: App.config.REDIS_URL)
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

      routing.get 'progress' do
        session[:id] ||= WanderWise::App.config.SESSION_SECRET
        progress_key = "progress:#{session[:id]}"
        logger.debug "Progress key: #{progress_key}"

        progress = redis.get(progress_key) || { status: 0 }.to_json
        logger.debug "Progress for key #{progress_key}: #{progress}"

        # Ensure the response is JSON-formatted
        response['Content-Type'] = 'application/json'
        progress
      end

      routing.root do
        processing = false
        view 'home'
      end

      routing.post 'submit' do # rubocop:disable Metrics/BlockLength
        session[:id] ||= WanderWise::App.config.SESSION_SECRET
        puts "Session ID: #{session[:id]}"

        logger.info 'Starting form validation'
        request = WanderWise::Forms::NewFlight.new.call(routing.params)
        if request.failure?
          session[:flash] = { error: request.errors.to_h.values.join(', ') }
          logger.error "Form validation failed: #{request.errors.to_h}"
          routing.redirect '/'
        end

        request_data = request.to_h
        logger.info "Form validation successful: #{request_data}"

        progress_key = "progress:#{session[:id]}"
        redis.set(progress_key, { status: 10 }.to_json)

        # Concurrent promises with progress updates
        flights_promise = Concurrent::Promise.execute do
          redis.set(progress_key, { status: 20 }.to_json)
          logger.debug "20% Flights promise started: #{redis.get(progress_key)}"
          result = Service::AddFlights.new.call(request_data)
          redis.set(progress_key, { status: 30 }.to_json)
          logger.debug "30% Flights promise completed: #{redis.get(progress_key)}"

          result
        end

        country_promise = Concurrent::Promise.execute do
          redis.set(progress_key, { status: 40 }.to_json)
          logger.debug "40% Country promise started: #{redis.get(progress_key)}"
          result = Service::FindCountry.new.call(request_data)
          redis.set(progress_key, { status: 50 }.to_json)
          logger.debug "50% Country promise completed: #{redis.get(progress_key)}"
          result
        end

        analyze_flights_promise = Concurrent::Promise.execute do
          redis.set(progress_key, { status: 60 }.to_json)
          logger.debug "60% Analyze flights promise started: #{redis.get(progress_key)}"
          result = Service::AnalyzeFlights.new.call(request_data)
          redis.set(progress_key, { status: 70 }.to_json)
          logger.debug "70% Analyze flights promise completed: #{redis.get(progress_key)}"
          result
        end

        articles_promise = country_promise.then do |country|
          if country.success?
            redis.set(progress_key, { status: 80 }.to_json)
            logger.debug "80% Articles promise started: #{redis.get(progress_key)}"
            Service::FindArticles.new.call(country.value!)
          else
            redis.set(progress_key, { status: 0 }.to_json)
            logger.error "Country promise failed: #{country.failure}"
            Concurrent::Promise.reject(country.failure)
          end
        end

        opinion_promise = Concurrent::Promise.zip(country_promise, analyze_flights_promise,
                                                  articles_promise).then do |(country, analyze_flights, articles)|
          if country.success? && analyze_flights.success? && articles.success?
            redis.set(progress_key, { status: 95 }.to_json)
            logger.debug "95% Opinion promise started: #{redis.get(progress_key)}"
            details = {
              month: routing.params['departureDate'].split('-')[1].to_i,
              destination: country.value!,
              origin: routing.params['originLocationCode'],
              historical_average_data: JSON.parse(analyze_flights.value!)['historical_average_data'],
              articles: articles.value!
            }
            result = Service::GetOpinion.new.call(details)
            redis.set(progress_key, { status: 97 }.to_json)
            logger.debug "97% Opinion promise completed: #{redis.get(progress_key)}"
            result
          else
            redis.set(progress_key, { status: 0 }.to_json)
            logger.error "Country, Analyze Flights, or Articles promise failed: #{country.failure}, #{analyze_flights.failure}, #{articles.failure}"
            'No opinion available' # Fallback
          end
        end

        logger.info 'Waiting for all promises to resolve'
        Concurrent::Promise.zip(
          flights_promise, country_promise, analyze_flights_promise, articles_promise, opinion_promise
        ).value!

        # Prepare data for rendering
        logger.info 'Collecting results'
        flight_data = redis.get("flights:#{request_data[:originLocationCode]}:#{request_data[:destinationLocationCode]}:#{request_data[:departureDate]}:#{request_data[:adults]}")

        if flight_data.nil?
          logger.info "Cache miss for flights: flights:#{request_data[:originLocationCode]}:#{request_data[:destinationLocationCode]}:#{request_data[:departureDate]}:#{request_data[:adults]}"
          flight_data = flights_promise.value!
          if flight_data.success?
            redis.set("flights:#{request_data[:originLocationCode]}:#{request_data[:destinationLocationCode]}:#{request_data[:departureDate]}:#{request_data[:adults]}", flight_data.value!.map(&:to_h).to_json, ex: 60)
            logger.info "Flight data cached."
          else
            logger.error "Failed to fetch flight data: #{flight_data.failure}"
          end
        else
          logger.info "Cache hit for flights."
          flight_data = JSON.parse(flight_data, symbolize_names: true)
        end

        country_result = country_promise.value!
        analyze_flights_result = analyze_flights_promise.value!
        articles_result = articles_promise.value!
        opinion_result = opinion_promise.value!

        errors = []
        errors << country_result.failure if country_result.failure?
        errors << analyze_flights_result.failure if analyze_flights_result.failure?
        errors << articles_result.failure if articles_result.failure?

        unless errors.empty?
          logger.error "Errors encountered: #{errors.join(', ')}"
          session[:flash] = { error: errors.join(', ') }
          routing.redirect '/'
        end

        redis.del(progress_key) # Clear progress tracking after completion

        destination_country = Views::Country.new(country_result.value!)
        historical_flight_data = Views::HistoricalFlightData.new(
          JSON.parse(analyze_flights_result.value!)['historical_average_data'],
          JSON.parse(analyze_flights_result.value!)['historical_lowest_data']
        )
        retrieved_articles = Views::ArticleList.new(articles_result.value!)
        gemini_answer = Views::Opinion.new(opinion_result)

        formatted_opinion = if gemini_answer.opinion
                              parsed_opinion = JSON.parse(gemini_answer.opinion.value!.gsub('Success(', '').gsub(/\)$/, ''))
                              parsed_opinion['opinion']
                                .gsub(/\\n/, '<br>') # Replace escaped newline sequences
                                .gsub(/\n/, '<br>')  # Replace actual newline characters
                                .gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>') # Bold formatting
                            else
                              'No opinion available.'
                            end

        view 'results', locals: {
          flight_data: Views::FlightList.new(flight_data.map(&:to_h)),
          country: destination_country,
          nytimes_articles: retrieved_articles,
          formatted_opinion: formatted_opinion,
          historical_data: historical_flight_data
        }
      rescue StandardError => e
        logger.error "Unexpected error: #{e.message}"
        logger.error e.backtrace.join("\n")
        flash[:error] = 'An unexpected error occurred'
        session[:flash] = flash.to_hash
        routing.redirect '/'
      end
    end
  end
end
