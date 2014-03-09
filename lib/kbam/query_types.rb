module Kbam
	module QueryTypes
		# query types
		SELECT = 0
		INSERT = 1
		DELETE = 2
		UPDATE = 3

		def self.get_name(query_type)
			case query_type
			when SELECT
				return 'SELECT'
			when INSERT
				return 'INSERT'
			when DELETE
				return 'DELETE'
			when UPDATE
				return 'UPDATE'
			else
				raise "Unknown name for query_type value #{query_type}"
			end
		end
	end
end