require 'sequel'

# Connect to the SQLite database
DB = Sequel.connect('sqlite://db/development.db')

require_relative 'app/infrastructure/database/flight_orm.rb' 
require_relative 'app/infrastructure/database/nytime_orm.rb'  
