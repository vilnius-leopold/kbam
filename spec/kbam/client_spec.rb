require 'spec_helper'

describe Kbam::Client do

	before do
		@client = Kbam::Client
	end

	it "should respond to #connect" do
		@client.should respond_to :connect
	end

	it "should respond to #query" do
		@client.should respond_to :connect
	end

	describe "::connect" do
		it "should be able to connect to a database when passing in valid paramters" do
			@client.connect(DatabaseCredentials)
		end

		it "it should fallback to default credentials if no other specified" do
			@client.connect({ 
				:pw   => "foodas4_the!sudas", 
				:db   => :kbam_test_db 
			})
		end

		it "it should raise an Kbam Client error if no database is specified" do
			expect {
				@client.connect({ 
					:pw   => "foodas4_the!sudas", 
				})
			}.to raise_error
		end

		it "it should raise an Kbam Client error if unable to connect" do
			expect {
				@client.connect({ 
					:host => :localhost, 
					:pw   => "fake_!pw", 
					:user => :root, 
					:db   => :kbam_test_db 
				})
			}.to raise_error
		end
	end

	describe "::query" do
		it "should be able to execute a query and return the Kbam Client result object" do
			@client.connect(DatabaseCredentials)

			result = @client.query("SELECT * FROM articles")

			# puts "RES: #{result.count}"

			result.should be_an_instance_of(Kbam::Result)
		end

		it "should raise an error if you're not connected yet" do
			expect {
				@client.close
				@client.query("SELECT * FROM articles")
			}.to raise_error
		end

		it "should raise an Kbam Client error when the query fails" do
			expect {
				@client.connect(DatabaseCredentials)
				@client.query("HOHOHO")
			}.to raise_error
		end
	end

end