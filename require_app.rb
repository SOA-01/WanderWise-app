# frozen_string_literal: true

def require_app
  Dir.glob('config/**/*.rb').each do |file|
    require_relative file
  end

  Dir.glob('app/**/*.rb').each do |file|
    require_relative file
  end
end
