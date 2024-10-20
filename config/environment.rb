require 'dotenv/load'

SECRETS = YAML.load_file(File.join(__dir__, 'secrets.yml'))