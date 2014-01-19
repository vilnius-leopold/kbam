require 'mysql2'   # the sql adapter
require 'colorize' # for error coloring ;)
require 'yaml'

# Kbam class / modules
require 'kbam/version.rb'
require 'kbam/extension.rb'

class Kbam
	attr_reader :is_nested
	attr_writer :is_nested

	@@client = nil
	@@sugar = false
	@@verbose = true

	# query_types
	SELECT = 0
	INSERT = 1
	UPDATE = 2

	#REVIEW/FIXME: remove instance connect?!
	# create instance connection --> for multiple database connections
	# maybe add settings --> allow separate client connections for each instance
	# use?
	# override default class connection if exists --> class fallback
	def initialize(login_credentials = nil)

		if login_credentials != nil
			warning "avoid connecting to the database for each instance"
			connect(login_credentials)
		end

		# query credentials
		@selects   = Array.new
		@from      = ""
		@wheres    = Array.new
		@or_wheres = Array.new
		@group     = ""
		@havings   = Array.new
		@orders    = Array.new
		@limit     = 1000
		@offset    = 0
		@query     = "" #raw query
		@as        = "t"
		@into      = ""
		@insert    = {}
		@insert_ignore = "" # will create a INSERT IGNORE statement 

		# meta data
		@last_query = nil
		@result     = nil
		@is_nested  = false
		@query_type = SELECT
		#@count_query = nil

		# offer block syntax
		if block_given?
			yield self
		end

	end

	##############
	# Pulbic API #
	##############

	#####################
	### Class methods ###

	# explicitly connect to database
	def self.connect(login_credentials = nil)
		if login_credentials != nil

			if @@client == nil
				if login_credentials.is_a? 'String' && login_credentials =~ /.+\.yml/
					login_credentials = YAML.load_file(login_credentials)
				end

				@@client = Mysql2::Client.new(login_credentials)
			else
				warning "you are already connected!"
			end
		else
			error "missing database credentials"
		end
	end

	# check if has syntax sugar
	def self.sugar?
		return @@sugar
	end

	def self.verbose(value)
		@@verbose = value
	end

	# sets sugar
	# REVIEW: add .no_sugar! if possible
	# or instance dependet sugar?
	def self.sugar_please!
		@@sugar = true
		require 'kbam/sugar.rb'
	end

	# escapes string
	# uses native mysql2 client
	def self.escape(string = nil)
		Mysql2::Client.escape string.to_s
	end

	# REVIEW: right approach?
	# needed when nesting queries --> class checking
	# def self.name
	# 	return "Kbam"
	# end

	# REVIEW: double check usage
	def self.clear
		@@wheres = Array.new
	end

	# FIXME: add symbole to string
	#   and decimal numbers
	# escapes variable and adds
	# backticks for strings
	def self.sanatize(item = nil)
		if item != nil
			if item.is_a?(Integer)
				item = item.to_i
			else
				item.to_s.strip!
				if item =~ /\A\d+\Z/
					item = item.to_i
				else
					item = "'#{Mysql2::Client.escape(item)}'"
					#item = "'#{item}'"
				end
			end
		else
			warning "can't sanatize nil class"
		end
		return item
	end

	# FIXME: add nil checking
	def self.replace(string = nil, values = nil)
		i = 0
		last_value = nil

		replaced_string = string.gsub(/\?/) do |match|
			if i > 0
				if values[i] != nil
					last_value = replacement = self.class.sanatize values[i]
				else
					replacement = last_value
				end
			else
				unless values[i] != nil
					puts "missing argument!"
				else
					last_value = replacement  = self.class.sanatize values[i]
				end
			end

			i += 1
			replacement
		end

		return replaced_string
	end

	########################
	### Instance methods ###

	# DEPRECATED?
	# explicitly connect to database
	def connect(login_credentials)
		self.connect(login_credentials)
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

	# REVIEW/DEPRECATED ?
	# FIXME: query auto execute? --> get?
	# FIXME: needs response/callback!
	def execute
		if @@verbose
			log(@query, "raw sql")
		end

		@@client.query(@query)
	end

	# FIXME: check nil / empty
	def select(*fields)
		fields = *fields.to_a

		fields.each do |field|

			#remove preceeding and trailing whitespaces and comma
			cleaned_select = field.to_s.gsub(/\s*\n\s*/, ' ').to_s.sub(/\A\s*,?\s*/, '').sub(/\s*,?\s*\Z/, '')#.gsub(/\s*,\s*/, ", ")

			#back-quote fieldnames
			# before NO '?<field>''
			cleaned_select.gsub! /(\w+)(?=\s+AS\s+)/ do |match|
				"#{field_sanatize($1)}" #before 'field' was '$1'
			end

			@selects.push(cleaned_select)
		end

		return self
	end

	# setter and getter AS
	def as(table_name = nil)
		if table_name != nil
			@as = table_name
			return self
		else
			return @as
		end
	end

	def ignore
		@insert_ignore = "IGNORE"
		return self
	end

	def insert(value_pair)
		@query_type = INSERT

		columns = ""
		values  = ""
		column_count = 0

		value_pair.each do |key, value|

			if column_count != 0
				values += ", "
				columns += ", "
			end

			columns += "#{field_sanatize(key.to_s)}"
			values  += "#{self.class.sanatize(value)}"

			column_count += 1
		end

		@insert = " (#{columns}) VALUES (#{values})"

		return self
	end

	def update(value_pair)

		@query_type = UPDATE

		@update = "SET "
		column_count = 0

		value_pair.each do |key, value|

			if column_count != 0
				@update += ", "
			end

			@update += "#{field_sanatize(key.to_s)} = #{self.class.sanatize(value)}"

			column_count += 1

		end

		return self

	end

	# used together with 'insert'
	def into(table)
		if @query_type === INSERT
			@into = "INSERT #{@insert_ignore} INTO #{field_sanatize(table)} "
		elsif @query_type === UPDATE
			@into = "UPDATE #{field_sanatize(table)}"
		end

		return self
	end

	def run
		if @query_type === INSERT
			# execute insert query
			@query = "#{@into} #{@insert}"
			execute

			# return the insert_id
			@query = "SELECT  LAST_INSERT_ID() AS insert_id;"
			query_result = execute

			insert_id = query_result.first["insert_id"]
			return insert_id
		elsif @query_type === UPDATE
			# execute insert query
			@query = "#{@into} #{@update} #{compose_where}"
			execute

			return true
		end
	end

	def from(from_string = nil)

		if from_string.class.name == "Kbam"
			from_string.is_nested = true
			@from = "(#{from_string.compose_query}\n   )AS #{from_string.as}"
		else
			if from_string != nil && from_string.to_s.strip! != ""
				@from = from_string
			else
				error "missing table"
			end
		end

		return self
	end

	def group(group_string = nil)
		if group_string != nil && group_string != ""
			@group = group_string
		else
			warning "group method is empty"
		end

		return self
	end

	# add class alias
	class << self
		alias :esc :escape
	end

	# where API
	def where(string, *value)

		values = *value.to_a

		#log string.class.name, "and log"

		if string.class.name == "Kbam"

			where_string = ""

			i = 0
			string.get_wheres.each do |w|
				if i > 0
					if w.sql_where_type == "or"
						where_string += " OR "
					else
						where_string += " AND "
					end
				end
				where_string += "#{w}\n   "
				i += 1
			end

			#puts "NESTED WHERE: #{where_string}"

			if where_string =~ /\s+OR\s+/i

				where_string	= "(#{where_string})"
			end
			where_string.set_sql_where_type("and")
			@wheres.push where_string
			string.clear

		else
			#puts "WHERE public input: #{value}"
			if string.respond_to?(:sql_prop) && (string.sql_prop != nil && string.sql_value != nil)
				where_statement = "`#{self.class.escape string.to_s}` #{string.sql_prop} #{self.class.sanatize string.sql_value}"
			elsif string !~ /\?/ && values.length == 1
				where_statement = "`#{self.class.escape string.to_s}` = #{self.class.sanatize values[0]}"

			else
				where_statement = replace(string, values)
				if string =~ /\s+or\s+/i
					where_statement	= "(#{where_statement})"
				end
			end

			if where_statement != ""
				where_statement.set_sql_where_type("and")
				@wheres.push where_statement
			end
		end

		#puts "WHERE after public input: #{where_statement}"

		return self

	end

	alias_method :and, :where

	# DEPRECATED
	def get_wheres
		@wheres
	end

	# REVIEW: right approach?
	# def name
	# 	return "Kbam"
	# end

	# What is this? remove?
	def clear
		@@wheres = Array.new
	end

	# where API
	def or_where(string, *value)

		values = *value.to_a

		if string.class.name == "Kbam"

			where_string = ""

			i = 0
			string.get_wheres.each do |w|
				if i > 0
					if w.sql_where_type == "or"
						where_string += " OR "
					else
						where_string += " AND "
					end
				end
				where_string += "#{w}\n   "
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

			if string.sql_prop != nil && string.sql_value != nil
				or_where_statement = "`#{self.class.escape string.to_s}` #{string.sql_prop} #{self.class.sanatize string.sql_value}"
			elsif string !~ /\?/ && values.length == 1
				or_where_statement = "`#{self.class.escape string.to_s}` = #{self.class.sanatize values[0]}"
			else
				or_where_statement = replace(string, values)
			end

			if string =~ /\s+AND\s+/i

				or_where_statement	= "(#{or_where_statement})"
			end

			if or_where_statement != ""
				or_where_statement.set_sql_where_type("or")
				@wheres.push or_where_statement
			end
		end

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

		@orders.push "#{field_sanatize(field)} #{sort_sanatize(direction)}"

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

	#REVIEW: using << instead of += --> faster
	def to_json(result)

		json = "{"

		# loop through rows
		i = 0
		result.each do |row|

			#add comma after each row
			if i > 0 then json << ", " end

			#puts row

			# use id as json keys
			json << "#{row["id"]}: {"

				# remove id
				row.delete("id")

				#use rest of fields as json value
				k = 0
				row.each do |key, value|
					if k > 0 then json << ", " end
					json << "#{key}: '#{value}'"
					k += 1
				end

			json << "}"

			i += 1
		end

		json << "}"

		return json
	end

	def get(format = "hash")

		format = format.to_s

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

	alias_method :fetch, :get

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

	#FIXME:
	def count
		if @result != nil
			return @result.count
		else
			warning "Can't count for empty result"
			return nil
		end
	end

	alias_method :length, :count

	def total
		if @result != nil
			@@client.query("SELECT FOUND_ROWS() AS count").first["count"]
		else
			warning "Can't count total for empty result"
		end
	end

	#FIXME: raw sql conflict and if not composed yet...
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

	#FIXME: change to class method
	# sanatize field
	def field_sanatize(field)
		field = field.to_s.strip
		#matches word character and between 2 and 64 character length
		if field =~ /\A[\w\.]{2,64}\Z/

			field.sub!(/\./, "`.`")

			return "`#{field}`"
		else
			error("invalid field name")
		end
	end

	def Kbam.sanatize_field!(dirty_string)
		dirty_string.replace(Kbam.sanatize_field(dirty_string))

		nil
	end

	# for sanatizing fields, tables
	def Kbam.sanatize_field(dirty_string)
		unless dirty_string.respond_to? :to_s
			raise ArgumentError,
				"Cannot convert #{dirty_string.class} into a String"
		end

		'`' << dirty_string.to_s.gsub(/[^a-zA-Z0-9_]/, '') << '`'
	end

	#FIXME: change to class method
	# senatize sort e.g. asc / desc
	def sort_sanatize(sort)

		sort = sort.to_s.strip.upcase

		#if it matches DESC or DSC
		if sort =~ /\ADE?SC\Z/
			return 'DESC'
		else
			return 'ASC'
		end
	end

	#####################
	# PRIVATE FUNCTIONS #
	#####################

	###################
	# Query composers #

	def compose_select
		select_string = "\nSELECT\n   "
		unless is_nested
			select_string += "SQL_CALC_FOUND_ROWS "
		end

		unless @selects.empty?
			select_string += "#{(@selects * ', ')}"
		else
			select_string += "*"
		end

		return select_string
	end

	def compose_from
		unless @from == ""
			"\nFROM\n   #{@from}"
		else
			error('No table specifiyed')
		end
	end

	def compose_group
		unless @group == ""
			"\nGROUP BY\n   #{@group}"
		else
			""
		end
	end

	def compose_where
		unless @wheres.empty?

			where_string = "\nWHERE\n   "

			i = 0
			@wheres.each do |w|
				if i > 0
					if w.sql_where_type == "or"
						where_string += "\n     OR "
					else
						where_string += "\n     AND "
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
			return "\nHAVING\n   #{(@havings * ' AND ')}"
		else
			return ""
		end
	end

	def compose_order
		unless @orders.empty?
			return "\nORDER BY\n   #{(@orders * ', ')}"
		else
			return ""
		end
	end

	def compose_limit
		unless @limit == nil
			return "\nLIMIT #{@limit}"
		else
			return "\nLIMIT 1000"
		end
	end

	def compose_offset
		unless @offset == nil || @offset == 0
			return "\nOFFSET #{@offset}"
		else
			return ""
		end
	end

	def compose_query

		# join the query fragments
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

		unless is_nested
			if @@verbose
				log(query_string, "query")
			end
		end

		@last_query = query_string

		return query_string

	end

	#####################
	# Private functions #

	# interrupts execution
	# creates error output
	def error(message)
		error_message = " ERROR: #{message}! "
		error_length = error_message.length
		puts ("="*error_length).colorize( :color => :red, :background => :white )
		puts error_message.colorize( :color => :red, :background => :white )
		puts ("="*error_length).colorize( :color => :red, :background => :white )

		Kernel::raise error_message
	end

	# creates warning
	# continues execution
	def warning(message)
		warning_message = " #{caller[0]} WARNING: #{message}! "
		warning_length = [warning_message.length, 80].min
		puts ("="*warning_length).colorize( :color => :yellow, :background => :white )
		puts warning_message.colorize( :color => :yellow, :background => :white )
		puts ("="*warning_length).colorize( :color => :yellow, :background => :white )
	end

	# prints debug info / log
	def log(message, title = nil)
		if title == nil
			title = "log"
		end
		color_width = 80
		title_length = title.length

		fill = color_width - title_length

		log_message = "#{message}"

		puts ("-"*color_width).colorize( :color => :black, :background => :white )
		puts "#{title.upcase}:#{" " * (fill - 1)}".colorize( :color => :black, :background => :white )
		puts ("-"*color_width).colorize( :color => :black, :background => :white )
		puts log_message.colorize( :color => :black, :background => :white )
		puts ("-"*color_width).colorize( :color => :black, :background => :white )
	end

	#takes only an array of values
	def replace(string, values)

		warning "DEPRECATED: use class method instead"

		i = 0
		last_value = nil

		replaced_string = string.to_s.gsub(/\?/) do |match|

			if i > 0
				if values[i] != nil
					last_value = replacement = self.class.sanatize values[i]
				else
					replacement = last_value
				end
			else
				unless values[i] != nil
					puts "missing argument!"
				else
					last_value = replacement  = self.class.sanatize values[i]
				end
			end

			i += 1

			replacement
		end

		return replaced_string

	end

end #END Kbam class
