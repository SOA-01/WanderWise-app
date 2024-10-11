require 'http'
require 'yaml'
require 'json'
require 'date'
require 'fileutils'

module WanderWise
    class AmadeusAPI
        attr_reader :secrets, :access_token

        def initialize
        @secrets = load_api_credentials
        @access_token = authenticate(secrets)
        end

        def load_api_credentials
        YAML.load_file('../config/secrets.yml')
        end

        def authenticate(secrets)
        auth_url = 'https://test.api.amadeus.com/v1/security/oauth2/token'
        response = HTTP.post(auth_url, form: {
                                grant_type: 'client_credentials',
                                client_id: secrets['amadeus_client_id'],
                                client_secret: secrets['amadeus_client_secret']
                            })
        JSON.parse(response.body.to_s)
        end

        def fetch_flight_offers(origin, destination, date, adults)
        params = {
            originLocationCode: origin,
            destinationLocationCode: destination,
            departureDate: date,
            adults: adults
        }

        fetch_response(access_token, params)
        end

        private

        def fetch_response(access_token, params)
        flight_offers_url = 'https://test.api.amadeus.com/v2/shopping/flight-offers'

        response = HTTP.auth("Bearer #{access_token}")
                        .get(flight_offers_url, params: params)

        JSON.parse(response.body.to_s)
        end
    end
end