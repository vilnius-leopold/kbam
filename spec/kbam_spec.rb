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

	describe ":verbose" do
		it "should output the query to the console as default or when turned on else off" do

		end
	end


	describe "#delete+#where" do
		it "should delete all records from a table that fullfil the where condition" do
			before_delete = Kbam.new.from(:comments).where(:user_name, 'Maryam').get.count
			before_delete.should be > 0

			Kbam.new.delete(:comments).where(:user_name, 'Maryam').run

			after_delete = Kbam.new.from(:comments).where(:user_name, 'Maryam').get.count
			after_delete.should be == 0

			# restore database
			# because after delete statement
			setup_database
		end
	end

	describe "#delete+#where+#limit" do
		it "should only delete a limited amount of records from a table that fullfil the where condition" do

			limit = 1

			before_delete = Kbam.new.from(:comments).where(:user_name, 'Maryam').get.count
			before_delete.should be > 0

			Kbam.new.delete(:comments).where(:user_name, 'Maryam').limit(limit).run

			after_delete = Kbam.new.from(:comments).where(:user_name, 'Maryam').get.count
			after_delete.should be == before_delete - limit

			# restore database
			# because after delete statement
			setup_database
		end
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

	describe "SELECT statement" do
		it "should create a valid statement even if the segments are chained randomly" do
			big_select = Kbam.new.select(:user_name, :id)
			                     .from(:comments)
			                     .where(:user_name, 'Yasir')
			                     .or_where(:user_name, 'Bell')
			                     .group(:id)
			                     .having(:user_name, 'Yasir')
			                     .order(:created_at, :desc)
			                     .limit(13)

			big_select_reverse = Kbam.new.limit(13)
			                     .order(:created_at, :desc)
			                     .having(:user_name, 'Yasir')
			                     .group(:id)
			                     .or_where(:user_name, 'Bell')
			                     .where(:user_name, 'Yasir')
			                     .from(:comments)
			                     .select(:user_name, :id)
			                     
			                     
			big_select_reverse.to_s.should be == big_select.to_s
			        
			query_string = big_select.to_s.gsub(/[\n\s]+/m, " ").strip

			reference_string "SELECT SQL_CALC_FOUND_ROWS `user_name`, `id` FROM `comments` WHERE `user_name` = 'Yasir' OR `user_name` = 'Bell' GROUP BY `id` HAVING `user_name` = 'Yasir' ORDER BY `created_at` DESC LIMIT 13"

			query_string.should be == reference_string
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