module WanderWise
    class Article
        attr_accessor :title, :published_date, :url
    
        def initialize(title:, published_date:, url:)
        @title = title
        @published_date = published_date
        @url = url
        end
    
        def to_s
        "#{title} (Published on #{published_date}) - #{url}"
        end
    end
end