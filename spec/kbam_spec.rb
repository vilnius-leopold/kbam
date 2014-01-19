require 'spec_helper'


describe Kbam do	
	before :all do
		Kbam.connect("#{Dir.pwd}/spec/database.yml")
	end

	before :each do
		@query = Kbam.new
	end

	describe "#from" do
		it "should return all results from the table for all syntaxes" do
			i = 0
			ref_result = nil

			[
				Kbam.new.from(:comments),
				Kbam.new.from("comments"),
				Kbam.new.from("`comments`"),
				Kbam.new.from("?", "comments"),
				Kbam.new.from("?", :comments),
				Kbam.new.from("?", "`comments`"),
				Kbam.new.from("`?`", "comments"),
				Kbam.new.from("`?`", :comments)
			].each do |query|
				result = []
				query.get.each do |row|
					result.push(row)
				end

				ref_result = result if i == 0

				ref_result.should eql result
			end

			ref_result.size.should be > 0
		end
	end
end