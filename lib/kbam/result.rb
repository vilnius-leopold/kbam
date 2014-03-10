module Kbam
	class Result
		include Enumerable

		def initialize (mysql2_result_object)
			@mysql2_result = mysql2_result_object
		end

		def [](index)
			unless @result_array
				@result_array = @mysql2_result.to_a
			end

			return @result_array[index]
		end

		def native
			return @mysql2_result
		end

		def each
			@mysql2_result.each do |row|
				yield row
			end
		end
	end
end