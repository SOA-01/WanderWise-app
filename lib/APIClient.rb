require 'http'
require 'yaml'
require 'json'
require 'date'
require 'fileutils'
require_relative 'AmadeusAPI'
require_relative 'NYTimesAPI'
require_relative 'FlightDetails'
require_relative 'Article'

module WanderWise
  class APIClient
    def initialize
      @AmadeusAPI = AmadeusAPI.new
      @NYTimesAPI = NYTimesAPI.new
    end

    def fetch_flight_data(origin, destination, date, adults)
      @AmadeusAPI.fetch_flight_offers(origin, destination, date, adults)
    end

    def fetch_articles(keyword)
      @NYTimesAPI.fetch_articles(keyword)
    end
  end
end