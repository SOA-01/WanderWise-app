# frozen_string_literal: true

module Views
  # View for a list of entities of historical flight data
  class HistoricalFlightData
    def initialize(historical_average_data, historical_lowest_data)
      @historical_average_data = historical_average_data
      @historical_lowest_data = historical_lowest_data
    end

    attr_reader :historical_average_data, :historical_lowest_data
  end
end
