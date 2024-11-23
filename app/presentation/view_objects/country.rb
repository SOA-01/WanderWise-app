# frozen_string_literal: true

module Views
  # View for a single entity of countries
  class Country
    attr_reader :country

    def initialize(country)
      @country = country
    end
  end
end
