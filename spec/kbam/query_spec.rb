require 'spec_helper'

describe Kbam::Query do
	before do
		Kbam::Client.connect(DatabaseCredentials)
	end

	describe "SELECT queries" do
		it "should return a result object" do
			result = Kbam::Query.new.from("articles").get

			puts "RESULT: #{result.inspect}"
			puts "RESULT: #{result.methods}"
			#puts "RESULT: #{result.fields}"

			result.each do |row|
				puts "test #{row}"
			end

			result.should be_instance_of(Kbam::Result)
		end
	end
end