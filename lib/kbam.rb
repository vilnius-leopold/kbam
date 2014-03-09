require 'kbam/client'
require 'kbam/version'
require 'kbam/composer'
require 'kbam/query_types'
require 'kbam/query'
require 'kbam/result'

module Kbam
	def self.new
		return Kbam::Query.new
	end

	def self.connect(credentials)
		Kbam::Client.connect(credentials)
	end

	def self.sanatize(dirty_string)
		Kbam::Client.sanatize(dirty_string)
	end
end