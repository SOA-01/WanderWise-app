# # frozen_string_literal: true

# module WanderWise
#   # Main class to run the application logic
#   class Main
#     def self.run
#       # ----- 1. Flight API -----
#       flight_mapper = WanderWise::FlightMapper.new(WanderWise::AmadeusAPI.new)
#       params = {
#         originLocationCode: 'TPE',
#         destinationLocationCode: 'LAX',
#         departureDate: (Date.today + 7).strftime('%Y-%m-%d'),
#         adults: 1
#       }
#       flight_mapper.save_flight_info_to_yaml(params, './spec/fixtures/flight-offers-results.yml')

#       # ----- 2. NY Times API -----
#       times_mapper = WanderWise::ArticleMapper.new(WanderWise::NYTimesAPI.new)
#       times_mapper.save_articles_to_yaml('Taiwan', './spec/fixtures/nytimes-results.yml')
#     end
#   end
# end

# # To execute the application logic
# WanderWise::Main.run unless File.exist?('./spec/fixtures/flight-offers-results.yml') && File.exist?('./spec/fixtures/nytimes-results.yml')
