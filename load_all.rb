# frozen_string_literal: true

require 'sequel'

# Connect to the SQLite database
DB = Sequel.connect('sqlite://db/local/dev.db')

require_relative 'app/infrastructure/database/orm/flight_orm'
require_relative 'app/infrastructure/database/orm/article_orm'
