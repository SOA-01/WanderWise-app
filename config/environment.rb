# frozen_string_literal: true

require 'roda'
require 'yaml'

module WanderWise
  # Configuration for the WanderWise app
  SECRETS = YAML.safe_load(File.read('config/secrets.yml'))
end
