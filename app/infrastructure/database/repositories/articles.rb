# frozen_string_literal: true

module WanderWise
  module Repository
    # Repository for Articles
    class Articles
      def self.find_id(id)
        rebuild_entity Database::ArticleOrm.where(id: id).all
      end

      def self.find_date(date)
        rebuild_entity Database::ArticleOrm.where(published_date: date).all
      end

      def self.rebuild_entity(db_record)
        return nil unless db_record

        db_record.map do |record|
          Entity::Article.new(
            id: record.id,
            title: record.title,
            published_date: record.published_date,
            url: record.url
          )
        end
      end

      def self.rebuild_many(db_records)
        db_records.map do |db_article|
          Articles.rebuild_entity(db_article)
        end
      end

      def self.create(entity)
        record = Database::ArticleOrm.create(
          title: entity.title,
          published_date: entity.published_date,
          url: entity.url
        )

        entity.id = record.id
        entity
      end

      def self.update(entity)
        Database::ArticleOrm.where(id: entity.id).update(
          title: entity.title,
          published_date: entity.published_date,
          url: entity.url
        )
      end

      def self.delete(id)
        Database::ArticleOrm.where(id: id).delete
      end
    end
  end
end
