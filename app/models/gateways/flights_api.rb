# frozen_string_literal: true

require 'http'
require 'yaml'
require 'json'
require_relative '../entities/flights_entity'

module WanderWise
  # Gateway to Amadeus API for flight offers data
  class FlightsAPI
    def initialize
      @secrets = YAML.load_file('./config/secrets.yml')
      @auth_data = authenticate
      @access_token = @auth_data['access_token']
    end

    # Fetch flight offers based on the provided parameters
    def fetch_response(params)
      flight_offers_url = 'https://test.api.amadeus.com/v2/shopping/flight-offers'

      response = HTTP.auth("Bearer #{@access_token}")
                     .get(flight_offers_url, params:)

      # Return the raw parsed JSON as a Ruby hash
      JSON.parse(response.body.to_s)
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
