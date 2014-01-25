require_relative '../lib/kbam.rb'
require_relative 'create_schema.rb'

# turn of kbam verbose query output
Kbam.verbose false

# initial setup of the database
setup_database