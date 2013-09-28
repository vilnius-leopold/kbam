
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


class String

	def >(value)
		@sql_prop = ">"
		@sql_value = value

		return self
	end

	def <(value)
		@sql_prop = "<"
		@sql_value = value

		return self
	end

	def <=(value)
		@sql_prop = "<="
		@sql_value = value

		return self
	end

	def >=(value)
		@sql_prop = ">="
		@sql_value = value

		return self
	end

	def like(value)
		@sql_prop = "LIKE"
		@sql_value = value

		return self
	end

	def sql_prop
		@sql_prop
	end

	def sql_value
		@sql_value		
	end
end

class Symbol

	def >(value)
		@sql_prop = ">"
		@sql_value = value

		return self
	end


	def <(value)
		@sql_prop = "<"
		@sql_value = value

		return self
	end

	def <=(value)
		@sql_prop = "<="
		@sql_value = value

		return self
	end

	def >=(value)
		@sql_prop = ">="
		@sql_value = value

		return self
	end

	def like(value)
		@sql_prop = "LIKE"
		@sql_value = value

		return self
	end

	def sql_prop
		@sql_prop
	end

	def sql_value
		@sql_value		
	end
end
