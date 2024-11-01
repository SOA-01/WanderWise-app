# FILEPATH: /home/linux/Desktop/Service_Oriented_Architecture/Tripplanner/WanderWise/spec/app_spec.rb

# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

require 'rspec'
require 'rack/test'
require 'vcr'
require_relative 'spec_helper'

ENV['RACK_ENV'] = 'test'

class Airport
  attr_reader :country

  def initialize(country)
    @country = country
  end
end

RSpec.describe WanderWise::App do # rubocop:disable Metrics/BlockLength
  include Rack::Test::Methods

  def app
    WanderWise::App.app
  end

  VCR.configure do |c|
    c.cassette_library_dir = 'spec/cassettes'
    c.hook_into :webmock
  end

  describe 'GET /' do
    it 'renders the home view' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include('Home')
      expect(last_response.body).to include('<title>My Trip Planner</title>') # Check if the title element is present
      expect(last_response.body).to include('form-horizontal') # Check if the form element is present
    end
  end

  describe 'POST /submit' do # rubocop:disable Metrics/BlockLength
    let(:amadeus_api) { instance_double(WanderWise::AmadeusAPI) }
    let(:flight_mapper) { instance_double(WanderWise::FlightMapper) }
    let(:nytimes_api) { instance_double(WanderWise::NYTimesAPI) }
    let(:article_mapper) { instance_double(WanderWise::ArticleMapper) }
    let(:params) { { 'originLocationCode' => 'TPE', 'destinationLocationCode' => 'LAX', 'departureDate' => '2024-10-29', 'adults' => '1' } }
    let(:flight_data) do
      [instance_double(WanderWise::Flight,
                       destination_location_code: 'LAX',
                       origin_location_code: 'TPE',
                       departure_date: '2024-10-29',
                       departure_time: '10:00',
                       arrival_time: '12:00',
                       price: '500',
                       airline: 'Delta',
                       duration: '2h')]
    end
    let(:country) { 'USA' }
    let(:nytimes_articles) do
      [instance_double(WanderWise::Article,
                       title: 'Example Article Title',
                       published_date: '2024-10-19',
                       url: 'https://example.com/article')]
    end

    before do
      allow(WanderWise::AmadeusAPI).to receive(:new).and_return(amadeus_api)
      allow(WanderWise::FlightMapper).to receive(:new).with(amadeus_api).and_return(flight_mapper)
      allow(WanderWise::NYTimesAPI).to receive(:new).and_return(nytimes_api)
      allow(WanderWise::ArticleMapper).to receive(:new).with(nytimes_api).and_return(article_mapper)
      allow(flight_mapper).to receive(:find_flight).with(params).and_return(flight_data)
      allow(Airports).to receive(:find_by_iata_code).with('LAX').and_return(instance_double(Airport, country:))
      allow(article_mapper).to receive(:find_articles).with(country).and_return(nytimes_articles)
    end

    it 'processes the form submission and renders the results view' do
      post '/submit', params
      expect(last_response).to be_ok
      expect(last_response.body).to include('Results')
    end

    it 'renders the error view on exception' do
      allow(flight_mapper).to receive(:find_flight).and_raise(StandardError.new('Test error'))
      post '/submit', params
      expect(last_response).to be_ok
      expect(last_response.body).to include('Error')
      expect(last_response.body).to include('Test error')
    end
  end
end
