# frozen_string_literal: true

require 'http'
require 'yaml'
require 'json'
require_relative '../../../models/entities/flight.rb'

module WanderWise
  # Gateway to Amadeus API for flight offers data
  class AmadeusAPI
    def initialize
      environment = ENV['RACK_ENV'] || 'development'
      secrets = YAML.load_file('./config/secrets.yml')
      @secrets = secrets[environment]
      @auth_data = authenticate
      @access_token = @auth_data['access_token']

      # Create a fixture file for the API response if it doesn't exist
      save_to_fixtures unless File.exist?('./spec/fixtures/flight-api-results.yml')
    end

    # Fetch flight offers based on the provided parameters
    def fetch_response(params)
      flight_offers_url = 'https://test.api.amadeus.com/v2/shopping/flight-offers'
      response = HTTP.auth("Bearer #{@access_token}")
                     .get(flight_offers_url, params:)
      flight_offers = JSON.parse(response.body.to_s)

      flight_offers
    end

    def save_to_fixtures
      date_next_week = (Date.today + 7).to_s # Find date of next week and convert to string

      flight_offers = fetch_response({ 'originLocationCode' => 'TPE', 'destinationLocationCode' => 'LAX', 'departureDate' => date_next_week,
                                       'adults' => '1' })
      File.open('./spec/fixtures/amadeus-results.yml', 'w') { |file| file.write(flight_offers.to_yaml) }
    end

    private

    # Authenticate with the Amadeus API to get an access token
    def authenticate
      auth_url = 'https://test.api.amadeus.com/v1/security/oauth2/token'
      response = HTTP.post(auth_url, form: {
                             grant_type: 'client_credentials',
                             client_id: @secrets['amadeus_client_id'],
                             client_secret: @secrets['amadeus_client_secret']
                           })
      # Return authentication details as a hash
      JSON.parse(response.body.to_s)
    end
  end
end
