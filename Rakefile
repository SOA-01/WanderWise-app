# frozen_string_literal: true

require 'rake/testtask'

CODE = 'app/application/controllers'

# Default task for Puma
task :default do
  if ENV['RACK_ENV'] == 'production'
    sh 'bundle exec puma -p 9000'
  else
    sh 'RACK_ENV=development bundle exec puma -p 9000'
  end
end

# Run tests for a merged coverage report
task :test do
  if ENV['RACK_ENV'] == 'production'
    puts 'Running tests in production mode'
    sh 'RACK_ENV=production COVERAGE=1 rspec spec/app_spec.rb'
    sh 'RACK_ENV=production COVERAGE=1 rspec spec/api_spec.rb'
    sh 'RACK_ENV=production COVERAGE=1 rspec spec/data_mapper_spec.rb'
  else
    puts 'Running tests in development mode'
    sh 'RACK_ENV=development COVERAGE=1 rspec spec/app_spec.rb'
    sh 'RACK_ENV=development COVERAGE=1 rspec spec/api_spec.rb'
    sh 'RACK_ENV=development COVERAGE=1 rspec spec/data_mapper_spec.rb'
  end
end

task :spec do
  ruby 'spec/spec_helper.rb'
end

task :new_session_secret do
  require 'base64'
  require 'securerandom'
  secret = SecureRandom.random_bytes(64).then { Base64.urlsafe_encode64(_1) }
  puts "SESSION_SECRET: #{secret}"
end

namespace :vcr do
  desc 'delete all cassettes'
  task :delete do
    rm_rf 'spec/cassettes'
  end
end

namespace :quality do
  desc 'run all quality checks'
  task all: %i[rubocop reek flog]
  task :rubocop do
    sh 'rubocop'
  end
  task :reek do
    sh 'reek'
  end
  task :flog do
    sh "flog#{CODE}"
  end
end

desc 'Run app console (irb)'
task :console do
  sh 'pry -r ./load_all.rb'
end
