module Kbam
	class Query
		def initialize
			@from   = nil
			@select = nil
			@where  = nil
			@order  = nil
			@limit  = nil
			@group  = nil
			@having = nil

			@insert = nil
			@into   = nil

			@update = nil
			@set    = nil

			@query_type = nil

			return self
		end

		def from(table_name)
			unless @query_type == nil || @query_type == Kbam::QueryTypes::SELECT
				raise "Query type already set to #{Kbam::QueryTypes.get_name(@query_type)}"
			end

			@query_type = Kbam::QueryTypes::SELECT 

			@from = table_name
			return self
		end

		def get
			unless @query_type == Kbam::QueryTypes::SELECT
				raise "Can't execute get on query_type #{Kbam::QueryTypes.get_name(@query_type)}"
			end

			select_query = Kbam::Composer.compose_query( get_query_params )

			return Kbam::Client.query(select_query)
		end

		def to_sql
			return Kbam::Composer.compose_select( get_query_params )
		end

		private
			def get_query_params
				case @query_type
				when Kbam::QueryTypes::SELECT
					query_params = {:select => @select, :from => @from}
				else
					raise "Can't get query params of invalid query type #{@query_type}"
				end

				query_params[:query_type] = @query_type

				return query_params
			end
	end
end