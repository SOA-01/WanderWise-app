# frozen_string_literal: true

require 'http'
require 'json'
require 'yaml'
require_relative '../../../models/entities/flight'

module WanderWise
  # Gateway to Amadeus API for flight offers data
  class AmadeusAPI
    def initialize
      environment = ENV['RACK_ENV'] || 'development'
      
      # Only load secrets from secrets.yml in development/test environments
      if environment == 'development' || environment == 'test'
        secrets_file_path = './config/secrets.yml'
        if File.exist?(secrets_file_path)
          secrets = YAML.load_file(secrets_file_path)
          @client_id = secrets[environment]['amadeus_client_id']
          @client_secret = secrets[environment]['amadeus_client_secret']
        else
          raise "secrets.yml file not found for #{environment} environment."
        end
      else
        # For production, use environment variables
        @client_id = ENV['AMADEUS_CLIENT_ID']
        @client_secret = ENV['AMADEUS_CLIENT_SECRET']
      end

      if @client_id.nil? || @client_secret.nil?
        raise 'AMADEUS_CLIENT_ID and AMADEUS_CLIENT_SECRET must be set in environment variables'
      end

      @auth_data = authenticate
      @access_token = @auth_data['access_token']

      # Create a fixture file for the API response if it doesn't exist
      save_to_fixtures unless File.exist?('./spec/fixtures/flight-api-results.yml')
    end

    # Fetch flight offers based on the provided parameters
    def fetch_response(params)
      flight_offers_url = 'https://test.api.amadeus.com/v2/shopping/flight-offers'
      response = HTTP.auth("Bearer #{@access_token}")
                     .get(flight_offers_url, params: params)
      JSON.parse(response.body.to_s)
    end

    def save_to_fixtures
      date_next_week = (Date.today + 7).to_s # Find date of next week and convert to string

      flight_offers = fetch_response({
        'originLocationCode' => 'TPE',
        'destinationLocationCode' => 'LAX',
        'departureDate' => date_next_week,
        'adults' => '1'
      })
      File.open('./spec/fixtures/amadeus-results.yml', 'w') { |file| file.write(flight_offers.to_yaml) }
    end

    private

    # Authenticate with the Amadeus API to get an access token
    def authenticate
      auth_url = 'https://test.api.amadeus.com/v1/security/oauth2/token'
      response = HTTP.post(auth_url, form: {
        grant_type: 'client_credentials',
        client_id: @client_id,
        client_secret: @client_secret
      })
      # Return authentication details as a hash
      JSON.parse(response.body.to_s)
    end
  end
end
