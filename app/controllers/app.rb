# frozen_string_literal: true

module WanderWise
  class Main
    def self.run
      # ----- 1. Flight API -----
      flight_mapper = WanderWise::FlightsMapper.new(WanderWise::FlightsAPI.new)
      params = {
        originLocationCode: 'TPE',
        destinationLocationCode: 'LAX',
        departureDate: '2024-10-19',
        adults: 1
      }
      flight_mapper.save_flight_info_to_yaml(params, './spec/fixtures/flight-offers-results.yml')

      # ----- 2. NY Times API -----
      times_mapper = WanderWise::NYTimesMapper.new(WanderWise::NYTimesAPI.new)
      times_mapper.save_articles_to_yaml('Taiwan', './spec/fixtures/nytimes-results.yml')
    end
  end
end

# To execute the application logic
WanderWise::Main.run