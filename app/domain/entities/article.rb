# frozen_string_literal: true

require 'dry-struct'
require 'dry-types'

# Define custom types for the article entity
module Types
  include Dry.Types()
end

module WanderWise
  # Domain entity for NY Times articles
  class Article < Dry::Struct
    attribute :title, Types::String
    attribute :published_date, Types::String
    attribute :url, Types::String
  end
end
