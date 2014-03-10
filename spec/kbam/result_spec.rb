require 'spec_helper'

describe Kbam::Result do
	before do
		Kbam.connect(DatabaseCredentials)
		@result =  Kbam.new.from(:articles).get
	end

	it "should be a kbam result object" do 
		@result.should be_instance_of(Kbam::Result)
	end

	it "should respond to method each" do
		@result.should respond_to(:each)
	end

	it "should respond to method [] and return a valid hash entry" do
		@result.should respond_to(:[])
		@result[0].should be_instance_of(Hash)
		@result[0].inspect.should == '{"id"=>1, "title"=>"arcu et pede. Nunc sed orci lobortis", "author"=>"Kasimir Curtis", "source_id"=>2, "created_at"=>2014-07-09 14:21:59 +0300}'
	end

	it "should respond to (Enumberable module) method first and return a valid hash entry" do
		@result.should respond_to(:first)
		@result.first.should be_instance_of(Hash)
		@result.first.inspect.should == '{"id"=>1, "title"=>"arcu et pede. Nunc sed orci lobortis", "author"=>"Kasimir Curtis", "source_id"=>2, "created_at"=>2014-07-09 14:21:59 +0300}'
	end

	it "should respond to method count and be greater than 0" do
		@result.should respond_to(:count)
		@result.count.should be > 0
	end

	it "should respond to method native and return the native result object" do
		@result.native.should be_instance_of(Mysql2::Result)
	end
end