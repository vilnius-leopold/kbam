# some syntax sugar 
# added to the String and Symbol class
# to handle sql operator
# <= >= < > .like

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
