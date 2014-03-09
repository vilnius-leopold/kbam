module Kbam
	class Result < Mysql2::Result
		include Enumerable

		def initialize (mysql2_result_object)
			#kbam_result = mysql2_result_object.to_a

			# kbam_result.each do |row|
			# 	puts "#{row}"
			# end

			@result = mysql2_result_object

			return @result
		end

		def each
			@result.each do |row|
				yield row
			end
		end
	end
end