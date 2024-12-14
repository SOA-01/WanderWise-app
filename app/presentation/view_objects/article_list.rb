# frozen_string_literal: true

module Views
  # View for a list of entities of articles
  class ArticleList
    def initialize(articles)
      @articles = JSON.parse(articles)['articles']
    end

    def each(&block)
      @articles.each(&block)
    end

    def any?
      @articles.any?
    end
  end
end
