# frozen_string_literal: true

require 'http'
require 'yaml'
require 'json'

module WanderWise
  # Handles the API calls to the Amadeus API
  class FlightsAPI
    def initialize
      @secrets = YAML.load_file('./config/secrets.yml')
      @auth_data = authenticate
      @access_token = @auth_data['access_token']
    end

    def fetch_response(params)
      flight_offers_url = 'https://test.api.amadeus.com/v2/shopping/flight-offers'

      response = HTTP.auth("Bearer #{@access_token}")
                     .get(flight_offers_url, params:)

      JSON.parse(response.body.to_s)
    end

    private

    def authenticate
      auth_url = 'https://test.api.amadeus.com/v1/security/oauth2/token'
      response = HTTP.post(auth_url, form: {
                             grant_type: 'client_credentials',
                             client_id: @secrets['amadeus_client_id'],
                             client_secret: @secrets['amadeus_client_secret']
                           })
      JSON.parse(response.body.to_s)
    end
  end
end
