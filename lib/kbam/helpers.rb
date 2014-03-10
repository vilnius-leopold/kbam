module Kbam
	module Helpers
		def self.sanatize(dirty_string)
			Mysql2::Client.escape(dirty_string)
		end

		def self.sanatize_field(dirty_string)
			"'#{Mysql2::Client.escape(dirty_string)}'"
		end
	end
end