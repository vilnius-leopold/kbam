require "kbam/version"

module Kbam
	def Kbam.test
		puts "Hello Kbam!"
	end

	def Kbam.sanatize_field(dirty_string = "")
		# sanatize it baby!
		sanatized_string = dirty_string.to_s
		                               .strip
		                               .gsub(/[^a-zA-Z0-9_]/, '')

		unless dirty_string == ""
			sanatized_string
		else
			puts "this is a empty string"
		end			
	end
end
