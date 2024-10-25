# frozen_string_literal: true

require 'roda'
require 'yaml'
require 'figaro'

module WanderWise
  # Configuration for the WanderWise app
  class App < Roda
    plugin :environments
    Figaro.application = Figaro::Application.new(
      environment: environment,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    SECRETS = YAML.safe_load(File.read('config/secrets.yml'))
  end
end
