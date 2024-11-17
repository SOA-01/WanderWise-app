# frozen_string_literal: true

require_relative 'entity'
require_relative 'flights'
require_relative 'articles'

module WanderWise
  module Repository
    # Repository for Entities
    module For
      ENTITY_REPOSITORY = {
        Entity::Flight => Flights,
        Entity::Article => Articles
      }.freeze

      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end
