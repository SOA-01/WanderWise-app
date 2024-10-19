# frozen_string_literal: true

require 'rake/testtask'

CODE = 'lib/'

task :default do
  ruby 'lib/main.rb'
end

task :test do
  ruby 'spec/api_spec.rb'
end

task :spec do
  ruby 'spec/spec_helper.rb'
end

task :run do
  ruby 'lib/main.rb'
end

task default: :run

namespace :vcr do
  desc 'delete all cassettes'
  task :delete do
    rm_rf 'spec/fixtures/cassettes'
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
