module Kbam
	module Composer
		def self.compose_query(params)
			query_type = params[:query_type]

			case query_type
			when Kbam::QueryTypes::SELECT
				return Composer.compose_select_query(params)
			else
				raise "Can't compose query string. Unknown query type #{query_type}"
			end
		end

		def self.compose_select_query(params)
			return "SELECT #{params[:select] || "*"} FROM #{params[:from]}"
		end
	end
end