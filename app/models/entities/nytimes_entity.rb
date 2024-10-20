# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

# Define custom types for the NY Times entity
module Types
  include Dry.Types()
end

module WanderWise
  # Domain entity for NY Times articles
  class NYTimesEntity < Dry::Struct
    attribute :title, Types::String
    attribute :published_date, Types::String
    attribute :url, Types::String

    def article_summary
      "#{title} (Published: #{published_date}) - URL: #{url}"
    end
  end
end
