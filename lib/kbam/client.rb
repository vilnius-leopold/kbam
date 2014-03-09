require 'mysql2'

module Kbam
	class Client
		@@client = nil

		def Client.connect(login_credentials)
			unless login_credentials && login_credentials.is_a?(Hash)
				raise "Nil or invalid format of login credentials:\n\
				       #{login_credentials}\n\
				       Require key value Hash."
			end

			login_credentials = Client.stringify_hash(login_credentials)

			host     = login_credentials["host"] || login_credentials["hostname"] || login_credentials["h"]   || "127.0.0.1"
			username = login_credentials["user"] || login_credentials["username"] || login_credentials["usr"] || login_credentials["u"] || "root"
			password = login_credentials["password"] || login_credentials["pw"]   || login_credentials["p"]   || nil
			database = login_credentials["database"] || login_credentials["db"]   || login_credentials["d"]   || nil

			unless database 
				raise "No database specified" 
			end

			@@client = Mysql2::Client.new(:host => host, :username => username, :password => password, :database => database)
		end

		def Client.query(query_string)
			unless @@client
				raise "You didn't connect to any database yet. Can't execute query."
			end


			result = @@client.query(query_string)

			puts "My2RES: #{result.inspect}"

			return Kbam::Result.new(result)
		end

		def Client.close(query_string)
			if @@client
				@@client.close
				@@client = nil
			else
				warn "Can't close non-existing connection."
			end
		end

		
		def Client.stringify_hash(hash)
			unless hash && hash.is_a?(Hash)
				raise "No valid Hash"
			end

			hash_array = hash.flatten

			hash_array.map! do |value|
				unless value.is_a?(String) ||  value.is_a?(Symbol) ||  value.is_a?(Integer)
					raise "Invalid hash value. Require type String, Symbol or Integer"
				end

				value.to_s
			end

			Hash[*hash_array]
		end

		def self.sanatize(dirty_string)
			return @client.sanatize(dirty_string)
		end

		def self.sanatize!(dirty_string)
			dirty_string.replace(@client.sanatize(dirty_string))
		end
	end
end