# frozen_string_literal: true

module Views
  # View for a single entity of opinions
  class Opinion
    attr_reader :opinion

    def initialize(opinion)
      @opinion = opinion
    end
  end
end
