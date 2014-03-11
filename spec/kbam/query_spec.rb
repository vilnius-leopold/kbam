require 'spec_helper'

describe Kbam::Query do
	before do
		Kbam::Client.connect(DatabaseCredentials)
	end

	describe "SELECT queries" do
		it "should return a result object" do
			result = Kbam::Query.new.from("articles").get

			result.should be_instance_of(Kbam::Result)
		end

		it "should raise an error if incompatible api verbs are cained" do
			expect{
				result = Kbam::Query.new.from("articles").insert({:title => "fake"}).get
			}.to raise_error
		end
	end
end