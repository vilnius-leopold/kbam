# cat lib/kbam.rb

require 'mysql2'   #the sql adapter
require 'colorize' #for error coloring ;)

class String

	@sql_where_type = "and" # :and, :or

	def sql_where_type
		puts "GET WHERE: #{@sql_where_type}"
		@sql_where_type
	end

	def set_sql_where_type(type)
		@sql_where_type = type
		puts "SET WHERE: #{@sql_where_type}"
	end
end

class Kbam
	
	@@client = nil
	@@wheres = Array.new
	
	def initialize(login_credentials = nil)

		# mysql2 client
		

		if login_credentials != nil
			connect(login_credentials)			
		end		

		# query credentials
		@selects 	= Array.new
		@from 		= ""
		@wheres 	= Array.new
		@or_wheres 	= Array.new
		@group		= ""
		@havings	= Array.new
		@orders 	= Array.new
		@limit 		= 1000
		@offset 	= 0
		@query 		= "" #raw query


		# meta data
		@last_query = nil
		@count_query = nil
		@result = nil

		
		# offer block syntax
		if block_given?
	      	yield self
	   	end

	end



	##############
	# Pulbic API #

	# Instance method: explicitly connect to database
	def connect(login_credentials)
		if @@client == nil
			@@client = Mysql2::Client.new(login_credentials)
		else
			puts "you are already connected!"
		end
	end

	# Class method: explicitly connect to database
	def self.connect(login_credentials)
		if @@client == nil
			@@client = Mysql2::Client.new(login_credentials)
		else
			puts "you are already connected!"
		end
	end

	# where API
	def query(string, *value)

		values = *value.to_a

		query_statement = replace(string, values)		

		if query_statement != ""
			@query = query_statement
		end

		return self
	end

	def execute()

		puts "executing: #{@query}"

		@@client.query(@query)
	end

	def select(*fields)
		fields = *fields.to_a

		
		fields.each do |field|

			#puts field

			#remove preceeding and trailing whitespaces and comma
			cleaned_select = field.gsub(/\s*\n\s*/, ' ').to_s.sub(/^\s*,?\s*/, '').sub(/\s*,?\s*$/, '')#.gsub(/\s*,\s*/, ", ")

			#back-quote fieldnames
			cleaned_select.gsub! /(\w+)(?=\s+AS\s+)/ do |match|
				"#{field_sanatize($1)}"
			end

			#"some, string AS stuff, comment.id"

			#puts cleaned_select

			@selects.push(cleaned_select)

		end

		return self

	end

	def from(from_string)
		@from = from_string

		return self
	end

	def group(group_string)
		@group = group_string

		return self
	end

	# where API
	def where(string, *value)

		#puts "WHERE public input: #{value}"

		values = *value.to_a

		where_statement = replace(string, values)

		if string =~ /\s+or\s+/i

			where_statement	= "(#{where_statement})"
		end

		if where_statement != ""
			where_statement.set_sql_where_type("and")
			@wheres.push where_statement
		end

		#puts "WHERE after public input: #{where_statement}"

		return self

	end

	alias_method :and, :where

	def self.where(string, *value)

		#puts "WHERE public input: #{value}"

		values = *value.to_a

		where_statement = replace(string, values)

		if string =~ /\s+or\s+/i

			where_statement	= "(#{where_statement})"
		end

		if where_statement != ""
			where_statement.set_sql_where_type("and")
			@@wheres.push where_statement
		end

		#puts "WHERE after public input: #{where_statement}"

		return self

	end



	def self.get_class_wheres
		@@wheres
	end

	def get_class_wheres
		@wheres
	end

	def self.name
		return "Kbam"
	end

	def name
		return "Kbam"
	end

	def self.clear
		@@wheres = Array.new
	end

	def clear
		@@wheres = Array.new
	end

		# where API
	def or_where(string, *value)

		#puts "WHERE public input: #{value}"

			values = *value.to_a

			puts "WHERE CLASS: #{string.class.name}"

		if string.name == "Kbam"

			where_string = ""

			i = 0
			string.get_class_wheres.each do |w|
				if i > 0
					if w.sql_where_type == "or"
						where_string += " OR "
					else
						where_string += " AND "
					end
				end
				where_string += "#{w}"
				i += 1
			end

			puts "NESTED WHERE: #{where_string}"

			if where_string =~ /\s+AND\s+/i

				where_string	= "(#{where_string})"
			end
			where_string.set_sql_where_type("or")
			@wheres.push where_string
			string.clear
		else

			or_where_statement = replace(string, values)

			if string =~ /\s+AND\s+/i

				or_where_statement	= "(#{or_where_statement})"
			end

			if or_where_statement != ""
				or_where_statement.set_sql_where_type("or")
				@wheres.push or_where_statement
			end
		end

		#puts "WHERE after public input: #{or_where_statement}"

		return self

	end

	alias_method :where_or, :or_where
	alias_method :or, :or_where

	# having API
	def having(string, *value)


		values = *value.to_a

		having_statement = replace(string, values)

		if string =~ /\s+or\s+/i

			having_statement	= "(#{having_statement})"
		end

		if having_statement != ""
			@havings.push having_statement
		end


		return self

	end

	def order(field, direction = nil)
		if direction == nil
			direction = 'ASC'
		end

		@orders.push  "#{field_sanatize(field)} #{sort_sanatize(direction)}"

		return self	
	end

	def limit(limit_int = nil)

		if limit_int != nil
			@limit = limit_int.to_i
		else
			@limit = nil
		end

		return self	
	end

	def offset(offset_int = nil)

		if offset_int != nil
			@offset = offset_int.to_i
		else
			@offset = nil
		end

		return self	
	end

	def to_json(result)

		json = "{"

		# loop through rows
		i = 0
		result.each do |row|

			#add comma after each row
			if i > 0 then json += ", " end

			#puts row

			# use id as json keys
			json += "#{row["id"]}: {"

				# remove id 
				row.delete("id")

				#use rest of fields as json value
				k = 0
				row.each do |key, value|
					if k > 0 then json += ", " end
					json += "#{key}: '#{value}'"
					k += 1
				end

			json += "}"

			i += 1
		end

		json += "}"

		return json
	end



	def get(format = "hash")

		format = format.to_s

		@wheres.each do |w|
			puts "test"
			puts "GET where: #{w.sql_where_type}"
		end
		
		case format
		when "json"
			#puts "FETCHING JSON"
			@result = to_json(@@client.query(compose_query))

		when "array"
			@result = @@client.query(compose_query, :as => :array)
		else
		  	@result = @@client.query(compose_query)
		end
			
		return @result
	end

	# if instance method 
	# then interferes with 
	# Array.each implementation!
	def each


		#puts "OBJECT TYPE: #{self.class}"

		if self.class == Kbam

			items = get

			if items != nil
				items.each do |item|
					yield item
				end
			else
				puts "Empty result"
			end

		else
			puts "No Kbam object found!"
		end
	end

	def count
		if @result != nil
			return @result.count
		else
			return nil
		end
	end

	alias_method :length, :count

	def total
		# unless @count_query == nil
		# 	total =  @@client.query(@count_query).first["count"]
		# 	puts "TOTAL COUNT: #{total}"
		# 	return total
		# else
		# 	error "Can't execute Kbam::count before Kbam::get or Kbam::each"
		# 	return nil
		# end

		@@client.query("SELECT FOUND_ROWS() AS count").first["count"]
		
	end

	def sql
		if @query == ""
			return compose_query
		else
			return @query
		end
	end

	alias_method :to_s, :sql
	alias_method :to_str, :sql
	alias_method :to_sql, :sql



	##################
	# Public helpers #

	# sanatize string
	def sanatize(item)
		if item.is_a?(Integer)
			item = item.to_i
		else
			item.strip!
			if item =~ /^\d+$/
				item = item.to_i
			else
				item = "'#{Mysql2::Client.escape(item)}'"
				#item = "'#{item}'"
			end
		end

		return item
	end

	def self.sanatize(item)
		if item.is_a?(Integer)
			item = item.to_i
		else
			item.strip!
			if item =~ /^\d+$/
				item = item.to_i
			else
				item = "'#{Mysql2::Client.escape(item)}'"
				#item = "'#{item}'"
			end
		end

		return item
	end

	# #sanatization not safe yet!!!
	# # sanatize text
	# def sanatize_text(item)
	# 	if item.is_a?(Integer)
	# 		item = item.to_i
	# 	else
	# 		item.strip!
	# 		if item =~ /^\d+$/
	# 			item = item.to_i
	# 		else
	# 			item = "'#{item.gsub(/\\/, '\&\&').gsub(/'/, "''")}'"
	# 			#item = "'#{item}'"
	# 		end
	# 	end

	# 	return item
	# end

	# sanatize field
	def field_sanatize(field)
		field = field.to_s.strip
		#matches word character and between 2 and 64 character length
		if field =~ /^[\w\.]{2,64}$/

			field.sub!(/\./, "`.`")

			return "`#{field}`"
		else
			error("invalid field name")
		end
	end

	# senatize sort e.g. asc / desc
	def sort_sanatize(sort)

		sort = sort.to_s.strip.upcase

		#if it matches DESC or DSC
		if sort =~ /^DE?SC$/
			return 'DESC'
		else
			return 'ASC'
		end
	end


	###################
	# Query composers #

	def compose_select
		unless @selects.empty?
			return "SELECT SQL_CALC_FOUND_ROWS #{(@selects * ', ')}"
		else
			return "SELECT *"
		end
	end

	def compose_from
		unless @from == ""
			"FROM #{@from}"
		else
			error('No table specifiyed')
		end
	end

	def compose_group
		unless @group == ""
			"GROUP BY #{@group}"
		else
			""
		end
	end

	def compose_where
		unless @wheres.empty?

			where_string = "WHERE "

			i = 0
			@wheres.each do |w|
				if i > 0
					if w.sql_where_type == "or"
						where_string += " OR "
					else
						where_string += " AND "
					end
				end
				where_string += "#{w}"
				i += 1
			end

			return where_string


		else
			return ""
		end
	end

	def compose_having
		unless @havings.empty?
			return "HAVING #{(@havings * ' AND ')}"
		else
			return ""
		end
	end

	def compose_order
		unless @orders.empty?
			return "ORDER BY #{(@orders * ', ')}"
		else
			return ""
		end
	end

	def compose_limit
		unless @limit == nil
			return "LIMIT #{@limit}"
		else
			return "LIMIT 1000"
		end
	end

	def compose_offset
		unless @offset == nil || @offset == 0
			return "OFFSET #{@offset}"
		else
			return ""
		end
	end

	def compose_query
		query_string = [
			compose_select, 
			compose_from, 
			compose_where,			
			compose_group,
			compose_having,
			compose_order,
			compose_limit, 
			compose_offset
		] * ' '

		puts "QUERY: #{query_string}"


		@last_query = query_string

		#puts "COUNT QUERY: #{count_query}"

		return query_string

	end
	

	#####################
	# Private functions #	

	def error(message)
		error_message = " ERROR: #{message}! "
		error_length = error_message.length
		puts ("="*error_length).colorize( :color => :red, :background => :white )
		puts error_message.colorize( :color => :red, :background => :white )
		puts ("="*error_length).colorize( :color => :red, :background => :white )
		
		Kernel::raise error_message
	end

	

	#takes only an array of values
	def replace(string, values)		

		i = 0
		last_value = nil

		replaced_string = string.gsub(/\?/) do |match|



			if i > 0 
				if values[i] != nil
					last_value = replacement = sanatize values[i]
				else
					replacement = last_value					
				end
			else
				unless values[i] != nil
					puts "missing argument!"
				else
					last_value = replacement  = sanatize values[i]
				end
			end

			i += 1

			replacement			
		end

		return replaced_string

	end

	def self.replace(string, values)		

		i = 0
		last_value = nil

		replaced_string = string.gsub(/\?/) do |match|



			if i > 0 
				if values[i] != nil
					last_value = replacement = sanatize values[i]
				else
					replacement = last_value					
				end
			else
				unless values[i] != nil
					puts "missing argument!"
				else
					last_value = replacement  = sanatize values[i]
				end
			end

			i += 1

			replacement			
		end

		return replaced_string

	end

end