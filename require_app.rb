# frozen_string_literal: true

def require_app
  files = Dir.glob('config/**/*.rb') + Dir.glob('app/**/*.rb')
  files.each do |file|
    require_relative file
  end
end
