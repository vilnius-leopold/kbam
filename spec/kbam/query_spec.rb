require 'spec_helper'

describe Kbam::Query do
	before do
		Kbam::Client.connect(DatabaseCredentials)
	end

	describe "SELECT queries" do
		it "should return a result object" do
			select_query = Kbam::Query.new

			result = select_query.from("articles").get

			result.should be_instance_of(Mysql2::Result)
		end
	end
end