# frozen_string_literal: true

require 'roda'
require 'slim'
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
        api = WanderWise::FlightsAPI.new
        mapper = WanderWise::FlightsMapper.new(api)

        begin
          flight_data = mapper.find_flight(routing.params)
          view 'results', locals: { flight_data: }
        rescue StandardError => e
          view 'error', locals: { message: e.message }
        end
      end
    end
  end
end
