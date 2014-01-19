require 'spec_helper'


describe Kbam do	
	before :all do
		Kbam.connect("#{Dir.pwd}/spec/database.yml")
		#Kbam.verbose false
	end

	before :each do
		@query = Kbam.new
	end

	describe "#from" do
		it "should return all results from the table for all syntaxes" do
			i = 0
			ref_result = nil

			[
				Kbam.new.from(:comments).limit(1).order(:id, :asc),
				Kbam.new.from("comments").limit(1).order(:id, :desc),
				Kbam.new.from("`comments`").limit(1).order(:id, :asc)#,
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

				puts "#{result.inspect}"
				puts "\nEQL: #{ref_result.uniq.sort == result.uniq.sort}\n"
				
				ref_result.size.should be result.size
				ref_result.should match_array result
			end

			ref_result.size.should be > 0
		end
	end
end