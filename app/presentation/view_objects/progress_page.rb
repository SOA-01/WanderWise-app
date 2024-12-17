# frozen_string_literal: true

module Views
  # View object to capture progress bar information
  class ProgressPage
    def initialize(config, response)
      @config = config
      @response = response
    end

    def in_progress?
      @response.processing?
    end

    def channel_id
      @response.message['request_id'] if in_progress?
    end

    def faye_javascript_url
      "#{@config.API_HOST}/faye/faye.js" if in_progress?
    end
  end
end
