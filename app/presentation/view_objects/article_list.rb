# frozen_string_literal: true

module Views
  # View for a list of entities of articles
  class ArticleList
    def initialize(articles)
      @articles = JSON.parse(articles)['articles']
    end

    def to_h
      @articles.map do |article|
        {
          title: article['title'],
          published_date: article['published_date'],
          url: article['url']
        }
      end
    end

    def each(&block)
      @articles.each(&block)
    end

    def any?
      @articles.any?
    end
  end
end
