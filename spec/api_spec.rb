require 'rspec'
require 'yaml'
require_relative '../lib/APIHandler'
require_relative '../lib/FlightDetails'
require_relative '../lib/Article'
require_relative 'spec_helper'

RSpec.describe WanderWise::APIHandler, :vcr do
  let(:api_handler) { WanderWise::APIHandler.new }
  let(:fixture_data) { YAML.load_file('spec/fixtures/results.yml') }

  describe '#fetch_flight_offers', :vcr do
    it 'retrieves valid flight offers from the API' do
      flight_offers = api_handler.fetch_flight_offers('TPE', 'LAX', '2024-10-07', 1)

      expect(flight_offers).not_to be_empty

      fixture_offer = fixture_data['flight_offers'].first
      api_offer = flight_offers.first

      expect(api_offer.origin).to eq(fixture_offer['origin'])
      expect(api_offer.destination).to eq(fixture_offer['destination'])
      expect(api_offer.departure_date).to eq(fixture_offer['departure_date'])
      expect(api_offer.price).to eq(fixture_offer['price'])
    end
  end

  describe '#fetch_articles', :vcr do
    it 'retrieves valid articles from the API' do
      articles = api_handler.fetch_articles('Taiwan')

      expect(articles).not_to be_empty

      fixture_article = fixture_data['articles'].first
      api_article = articles.first

      expect(api_article.title).to eq(fixture_article['title'])
      expect(api_article.published_date).to eq(fixture_article['published_date'])
      expect(api_article.url).to eq(fixture_article['url'])
    end
  end
end
