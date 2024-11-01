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

  let(:amadeus_api) { WanderWise::Amadeus.new }

  # Get path through expanding the current directory
  curr_dir = __dir__
  let(:fixture_flight) { YAML.load_file("#{curr_dir}/fixtures/flight-api-results.yml") }

  params = { 'originLocationCode' => 'TPE', 'destinationLocationCode' => 'LAX', 'departureDate' => '2024-10-29', 'adults' => '1' }

  describe '#api call to amadeus', :vcr do
    it 'receives valid JSON response from the API' do
      flight_offers = amadeus_api.fetch_response(params)

      expect(flight_offers).not_to be_empty

      # flight_offers first element of data will be compared to the fixture yaml file in its structure
      api_offer = flight_offers['data'].first
      fixture_offer = fixture_flight['data'].first

      # Check if first 5 keys match
      expect(api_offer.keys[0..4]).to eq(fixture_offer.keys[0..4])
    end
  end
end

RSpec.describe WanderWise::NYTimesAPI do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
  end

  before do
    VCR.insert_cassette CASSETTE_FILE_NYT,
                        record: :new_episodes,
                        match_requests_on: %i[method uri body]
  end

  let(:nytimes_api) { WanderWise::NYTimesAPI.new }

  curr_dir = __dir__
  let(:fixture_articles) { YAML.load_file("#{curr_dir}/fixtures/nytimes-api-results.yml") }

  describe '#articles', :vcr do
    it 'gets valid JSON with articles' do
      api_articles = nytimes_api.fetch_recent_articles('China')
      expect(api_articles).not_to be_empty

      # flight_offers first element of data will be compared to the fixture yaml file in its structure
      api_example = api_articles['response']['docs'].first

      fixture_example = fixture_articles['response']['docs'].first
      # Check if first 5 keys match
      expect(api_example.keys[0..4]).to eq(fixture_example.keys[0..4])
    end
  end
end
