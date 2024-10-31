require 'sequel'

# Connect to the SQLite database
DB = Sequel.connect('sqlite://db/local/dev.db')

require_relative 'app/infrastructure/database/orm/flight_orm.rb' 
require_relative 'app/infrastructure/database/orm/article_orm.rb'  
