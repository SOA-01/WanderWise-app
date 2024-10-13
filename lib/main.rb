# Example usage
require_relative 'APIClient'

client = WanderWise::APIClient.new

# Fetching flight offers
flight_offers = client.fetch_flight_data('TPE', 'LAX', '2024-10-07', 1)
flight_offers.each { |offer| puts offer }

# Fetching articles
articles = client.fetch_articles('Taiwan')
articles.each { |article| puts article }


