# frozen_string_literal: true

require 'rspec'
require 'yaml'
require 'simplecov'
SimpleCov.start

require_relative 'spec_helper'

RSpec.describe WanderWise::AmadeusAPI do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
  end

  before do
    VCR.insert_cassette CASSETTE_FILE_FLIGHTS,
                        record: :new_episodes,
                        match_requests_on: %i[method uri body]
  end

  after do
    VCR.eject_cassette
  end

  let(:amadeus_api) { WanderWise::AmadeusAPI.new } 

  # Get path through expanding the current directory
  curr_dir = __dir__
  let(:fixture_flight) { YAML.load_file("#{curr_dir}/fixtures/flight-api-results.yml") }

  params = { 'originLocationCode' => 'TPE', 'destinationLocationCode' => 'LAX', 'departureDate' => '2024-10-29', 'adults' => '1' }

  describe '#api call to Amadeus', :vcr do
    it 'receives valid JSON response from the API' do
      flight_offers = amadeus_api.fetch_response(params)

      expect(flight_offers).not_to be_empty

      # Compare the API response with the fixture
      api_offer = flight_offers['data'].first
      fixture_offer = fixture_flight['data'].first

      # Check if first 5 keys match
      expect(api_offer.keys[0..4]).to eq(fixture_offer.keys[0..4])
    end
  end
end

# Test for FlightMapper class (if applicable)
RSpec.describe WanderWise::FlightMapper do
  let(:amadeus_api) { WanderWise::AmadeusAPI.new }
  let(:flight_mapper) { WanderWise::FlightMapper.new(amadeus_api) } 

  params = { 'originLocationCode' => 'TPE', 'destinationLocationCode' => 'LAX', 'departureDate' => '2024-10-29', 'adults' => '1' }

  describe '#find_flight' do
    it 'returns an array of sorted flight entities' do
      flights = flight_mapper.find_flight(params)

      expect(flights).to be_an(Array)
      expect(flights).not_to be_empty
      expect(flights.first).to be_a(WanderWise::Flight)
    end
  end
end
