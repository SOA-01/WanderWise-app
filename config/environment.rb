# frozen_string_literal: true

require 'dotenv/load'

SECRETS = YAML.load_file(File.join(__dir__, 'secrets.yml'))
