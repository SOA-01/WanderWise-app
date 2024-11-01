# frozen_string_literal: true

require 'simplecov'
SimpleCov.start
require 'rspec'
require_relative 'spec_helper'
require 'vcr'

RSpec.describe WanderWise::FlightMapper do
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

  let(:gateway) { WanderWise::Amadeus.new }
  let(:mapper) { WanderWise::FlightMapper.new(gateway) }

  curr_dir = __dir__
  let(:fixture_flight) { YAML.load_file("#{curr_dir}/fixtures/flight-api-results.yml") }

  describe '#find_flight' do
    it 'transforms API response into FlightsEntity object' do
      params = { originLocationCode: 'TPE', destinationLocationCode: 'LAX', departureDate: '2024-10-29', adults: 1 }
      
      flight = mapper.find_flight(params).first

      expect(flight).to be_a(WanderWise::Flight)
      expect(flight.origin_location_code).to eq(fixture_flight['data'].first.dig('itineraries', 0, 'segments', 0, 'departure', 'iataCode'))
      expect(flight.destination_location_code).to eq(fixture_flight['data'].first.dig('itineraries', 0, 'segments', -1, 'arrival', 'iataCode'))
    end
  end
end

RSpec.describe WanderWise::ArticleMapper do
  VCR.configure do |c|
    c.cassette_library_dir = CASSETTES_FOLDER
    c.hook_into :webmock
  end

  before do
    VCR.insert_cassette CASSETTE_FILE_NYT,
                        record: :new_episodes,
                        match_requests_on: %i[method uri body]
  end

  after do
    VCR.eject_cassette
  end

  let(:gateway) { WanderWise::NYTimesAPI.new }
  let(:mapper) { WanderWise::ArticleMapper.new(gateway) }

  curr_dir = __dir__
  let(:fixture_articles) { YAML.load_file("#{curr_dir}/fixtures/nytimes-api-results.yml") }

  describe '#find_articles' do
    it 'transforms API response into an array of ArticleEntity objects' do
      articles = mapper.find_articles('Taiwan')
      
      expect(articles).to be_an(Array)
      expect(articles.first).to be_a(WanderWise::Article)
      # expect(articles.first.title).to eq(fixture_articles.first.dig('headline', 'main'))
      # expect(articles.first.published_date).to eq(fixture_articles.first['pub_date'])
      # expect(articles.first.url).to eq(fixture_articles.first['web_url'])
    end
  end
end
