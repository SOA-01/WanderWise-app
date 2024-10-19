# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

module Types
  # Use the new Dry.Types() syntax
  include Dry.Types()
end

module WanderWise
  # Domain entity for NY Times articles
  class NYTimesEntity < Dry::Struct
    # Define the attributes with explicit types
    attribute :title, Types::String
    attribute :published_date, Types::String
    attribute :url, Types::String

    def article_summary
      "#{title} (Published: #{published_date}) - URL: #{url}"
    end
  end
end
