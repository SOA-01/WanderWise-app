# frozen_string_literal: true

require 'roda'
require 'slim'
require 'airports'
require_relative '../models/gateways/flights_api'
require_relative '../models/gateways/nytimes_api'

module WanderWise
  # Main application class for WanderWise
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :common_logger, $stderr
    plugin :halt

    route do |routing|
      routing.assets

      # GET / request
      routing.root do
        view 'home'
      end

      # POST /submit request
      routing.post 'submit' do
        puts "Form submitted: #{routing.params}"
        flights_api = WanderWise::FlightsAPI.new
        flight_mapper = WanderWise::FlightsMapper.new(flights_api)
        nytimes_api = WanderWise::NYTimesAPI.new
        nytimes_mapper = WanderWise::NYTimesMapper.new(nytimes_api)

        begin
          flight_data = flight_mapper.find_flight(routing.params)
          country = Airports.find_by_iata_code(flight_data.first.destination_location_code).country

          nytimes_articles = nytimes_mapper.find_articles(country)
          view 'results', locals: { flight_data:, country:, nytimes_articles: }
        rescue StandardError => error
          view 'error', locals: { message: error.message }
        end
      end
    end
  end
end
