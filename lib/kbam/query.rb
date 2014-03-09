module Kbam
	class Query
		# query types
		SELECT = 0
		INSERT = 1
		DELETE = 2
		UPDATE = 3

		@@query_type_names = {}
		@@query_type_names[SELECT] = 'SELECT'
		@@query_type_names[INSERT] = 'INSERT'
		@@query_type_names[DELETE] = 'DELETE'
		@@query_type_names[UPDATE] = 'UPDATE'

		def initialize
			@from   = nil
			@select = nil
			@where  = nil
			@order  = nil
			@limit  = nil
			@group  = nil
			@having = nil

			@query_type = nil

			return self
		end

		def from(table_name)
			unless @query_type == nil || @query_type == SELECT
				raise "Query type already set to #{@@query_type_names[@query_type]}"
			end

			@query_type = SELECT 

			@from = table_name
			return self
		end

		def get
			unless @query_type == SELECT
				raise "Can't execute get on query_type #{@query_type}"
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
				when SELECT
					query_params = {:select => @select, :from => @from}
				else
					raise "Can't get query params of invalid query type #{@query_type}"
				end

				query_params[:query_type] = @query_type

				return query_params
			end
	end
end