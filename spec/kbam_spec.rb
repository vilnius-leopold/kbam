require 'spec_helper'
require 'json'


describe Kbam do	
	before :all do
		Kbam.connect("#{Dir.pwd}/spec/database.yml", :testing)
		#Kbam.verbose false
	end

	before :each do
		@query = Kbam.new
	end

	describe "#from" do
		it "should return all rows of the specifyed table when used alone" do
			i = 0
			ref_result = nil

			[
				Kbam.new.from(:comments),
				Kbam.new.from("comments"),
				Kbam.new.from("`comments`")#,
				# Kbam.new.from("?", "comments"),
				# Kbam.new.from("?", :comments),
				# Kbam.new.from("?", "`comments`"),
				# Kbam.new.from("`?`", "comments"),
				# Kbam.new.from("`?`", :comments)
			].each do |query|
				result = []

				query.get.each do |row|
					result.push(row)
				end

				ref_result = result if i == 0

				ref_result.to_json.should == result.to_json

				i += 1
			end

			ref_result.size.should be > 0
		end

		it "should create the same query string for all syntaxes" do
		end

		it "should sanatize and backtick-quote table names" do
		end

		it "should be able to take on other query object for nesting" do 
		end
	end

	describe "#select" do
		it "should sanatize and backtick-quote fields" do
		end

		it "should generate the same query string for all syntaxes" do
		end

		it "should recognize AS alias statements" do 
		end

		it "should allow the use of SQL functions" do
		end
	end
end