# frozen_string_literal: true

module Views
  # View for a single entity of articles
  class Article
    def initialize(article)
      @article = article
    end

    def entity
      @article
    end

    def title
      @article.title
    end

    def published_date
      @article.published_date
    end

    def url
      @article.url
    end
  end
end
