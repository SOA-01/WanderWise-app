# frozen_string_literal: true

require 'roda'
require 'slim'
require 'airports'
require_relative '../infrastructure/amadeus/gateways/amadeus_api'
require_relative '../infrastructure/nytimes/gateways/nytimes_api'
require_relative '../infrastructure/database/repositories/flights.rb'

module WanderWise
  # Main application class for WanderWise
  class App < Roda
    plugin :render, engine: 'slim', views: 'app/views'
    plugin :assets, css: 'style.css', path: 'app/views/assets'
    plugin :halt

    route do |routing|
      routing.assets

      # GET / request
      routing.root do
        view 'home'
      end

      # POST /submit request
      routing.post 'submit' do
        amadeus_api = WanderWise::AmadeusAPI.new
        flight_mapper = WanderWise::FlightMapper.new(amadeus_api)
        nytimes_api = WanderWise::NYTimesAPI.new
        article_mapper = WanderWise::ArticleMapper.new(nytimes_api)

        begin
          flight_data = flight_mapper.find_flight(routing.params)
          country = Airports.find_by_iata_code(flight_data.first.destination_location_code).country
          Repository::For.klass(Entity::Flight).create_many(flight_data)
          nytimes_articles = article_mapper.find_articles(country)
          view 'results', locals: { flight_data:, country:, nytimes_articles: }
        rescue StandardError => error
          view 'error', locals: { message: error.message }
        end
      end
    end
  end
end
