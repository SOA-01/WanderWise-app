require 'rspec'
require 'yaml'
require_relative '../lib/APIHandler'
require_relative '../lib/FlightDetails'
require_relative '../lib/Article'

RSpec.describe WanderWise::APIHandler do
  let(:api_handler) { WanderWise::APIHandler.new }  # Ensure correct namespacing
  let(:fixture_data) { YAML.load_file('spec/fixtures/results.yml') }

  describe '#fetch_flight_offers' do
    it 'retrieves valid flight offers from the API' do
      flight_offers = api_handler.fetch_flight_offers('TPE', 'LAX', '2024-10-07', 1)

      # Assert that at least one flight offer is retrieved
      expect(flight_offers).not_to be_empty

      # Compare the first offer with the fixture data
      fixture_offer = fixture_data['flight_offers'].first
      api_offer = flight_offers.first

      expect(api_offer.origin).to eq(fixture_offer['origin'])
      expect(api_offer.destination).to eq(fixture_offer['destination'])
      expect(api_offer.departure_date).to eq(fixture_offer['departure_date'])
      expect(api_offer.price).to eq(fixture_offer['price'])
    end
  end

  describe '#fetch_articles' do
    it 'retrieves valid articles from the API' do
      articles = api_handler.fetch_articles('Taiwan')

      # Assert that at least one article is retrieved
      expect(articles).not_to be_empty

      # Compare the first article with the fixture data
      fixture_article = fixture_data['articles'].first
      api_article = articles.first

      expect(api_article.title).to eq(fixture_article['title'])
      expect(api_article.published_date).to eq(fixture_article['published_date'])
      expect(api_article.url).to eq(fixture_article['url'])
    end
  end
end