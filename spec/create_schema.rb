require 'yaml'

def setup_database
	# read database credentials
	db_credentials = YAML.load_file("#{Dir.pwd}/spec/database.yml")["testing"]
	db_credentials["password"].gsub('!', "'!'")
	# puts "CREDENTIALS:\n#{db_credentials}\n"

	script_direcotry = "#{Dir.pwd}/spec/database"
	scheme_script = "#{script_direcotry}/scheme.sql"

	command_string = "mysql -u#{db_credentials["username"]} -p#{db_credentials["password"]} -e"

	puts "Creating database..."
	system("#{command_string} 'DROP SCHEMA IF EXISTS `#{db_credentials["database"]}`;'")
	system("#{command_string} 'CREATE SCHEMA `#{db_credentials["database"]}`;'")
	system("#{command_string} 'USE `#{db_credentials["database"]}`;'")

	puts "Creating database scheme..."
	output = system("mysql -u#{db_credentials["username"]} -p#{db_credentials["password"]} #{db_credentials["database"]} < #{scheme_script};")
	raise "ERROR: Failed to create databse scheme.\n#{output}" unless output == true

	# insert data
	puts "Inserting dummy data..."
	Dir["#{script_direcotry}/data/*.sql"].each do |script|
		output = system("mysql -u#{db_credentials["username"]} -p#{db_credentials["password"]} #{db_credentials["database"]}  < #{script};")

		raise "ERROR: Failed to execute script '#{script}'\n#{output}" unless output == true
	end

	puts "Done."
end
