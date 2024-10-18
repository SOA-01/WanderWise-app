require 'http'
require 'yaml'
require 'json'
require_relative 'FlightsEntity'
require_relative 'NYTimesEntity'


# ----- 1. Flight API -----
flightEntity = WanderWise::FlightsEntity.new
flightEntity.yaml_flight_info

# ----- 2. NY API -----
keyword = 'Taiwan' # Change the keyword to what you want
timesEntity = WanderWise::NYTimesEntity.new
timesEntity.save_articles_to_yaml
