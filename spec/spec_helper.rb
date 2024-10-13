require 'simplecov'
require 'vcr'
require 'webmock/rspec'

SimpleCov.start do
  add_filter '/spec/'    
  add_filter '/config/'  
  add_filter '/vendor/'   
end

puts "SimpleCov started"

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/cassettes'  
  config.hook_into :webmock                                    
  config.filter_sensitive_data('<SAFE_AMADEUS_CLIENT_ID>') { ENV['AMADEUS_CLIENT_ID'] }
  config.filter_sensitive_data('<SAFE_AMADEUS_CLIENT_SECRET>') { ENV['AMADEUS_CLIENT_SECRET'] }
  config.filter_sensitive_data('<SAFE_NYTIMES_API_KEY>') { ENV['NYTIMES_API_KEY'] }
  config.configure_rspec_metadata!                             
end

