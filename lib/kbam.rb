# cat lib/kbam.rb

require 'mysql2'   #the sql adapter
require 'colorize' #for error coloring ;)

class Kbam
	
	def initialize(login_credentials = nil)

		# mysql2 client
		@client = nil

		if login_credentials != nil
			connect(login_credentials)			
		end		

		# query credentials
		@selects 	= Array.new
		@from 		= ""
		@wheres 	= Array.new
		@orders 	= Array.new
		@limit 		= 1000
		@offset 	= 0

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

	# explicitly connect to database
	def connect(login_credentials)
		if @client == nil
			@client = Mysql2::Client.new(login_credentials)
		else
			puts "you are already connected!"
		end
	end

	def select(*fields)
		fields = *fields.to_a

		
		fields.each do |field|

			#puts field

			#remove preceeding and trailing whitespaces and comma
			cleaned_select = field.to_s.sub(/^\s*,?\s*/, '').sub(/\s*,?\s*$/, '').gsub(/\s*,\s*/, ", ")

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

	# where API
	def where(string, *value)

		values = *value.to_a

		where_statement = replace(string, values)

		if string =~ /\s+or\s+/i

			where_statement	= "(#{where_statement})"
		end

		@wheres.push where_statement

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

	

	def get

		@result = @client.query(compose_query)

		return @result
	end

	# if instance method 
	# then interferes with 
	# Array.each implementation!
	def each


		puts "OBJECT TYPE: #{self.class}"

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

	def total
		unless @count_query == nil
			total =  @client.query(@count_query).first["count"]
			puts "TOTAL COUNT: #{total}"
			return total
		else
			error "Can't execute Kbam::count before Kbam::get or Kbam::each"
			return nil
		end
		
	end

	def sql
		return compose_query
	end


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
				item = "'#{@client.escape(item)}'"
				#item = "'#{item}'"
			end
		end

		return item
	end

	# sanatize field
	def field_sanatize(field)
		field = field.to_s.strip
		#matches word character and between 2 and 64 character length
		if field =~ /^[\w]{2,64}$/

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
			return "SELECT #{(@selects * ', ')}"
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

	def compose_where
		unless @wheres.empty?
			return "WHERE #{(@wheres * ' AND ')}"
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
			compose_order, 
			compose_limit, 
			compose_offset
		] * ' '

		puts "QUERY: #{query_string}"

		count_query = [
			"SELECT COUNT(*) AS count", 
			compose_from, 
			compose_where
		] * ' '

		@last_query = query_string

		@count_query = count_query

		puts "COUNT QUERY: #{count_query}"

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

end