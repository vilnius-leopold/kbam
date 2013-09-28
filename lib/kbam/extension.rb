# adds extension to the String class
# to handle where and/or nicely
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