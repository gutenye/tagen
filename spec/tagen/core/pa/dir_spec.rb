require "spec_helper"
require "fileutils"
require "tmpdir"

describe Pa do
	before :all do
		$tmpdir = Dir.mktmpdir
		Dir.chdir($tmpdir)
	end

	after(:all) do
		FileUtils.rm_r $tmpdir
	end

	describe "#glob" do
		before(:all) do 
			FileUtils.touch(%w(fa .fa))
		end

		context "call without any option" do
			it "returns 1 items" do
				Pa.glob("*").should have(1).items
			end
		end

		context "call with :dotmatch option" do
			it "returns 2 items" do
				Pa.glob("*", dotmatch: true).should have(2).items
			end
		end
	end

	describe "#each" do
		# fa .fa fa~ 
		# dira/
		#   dirb/
		#     b
		before(:all) do
			FileUtils.mkdir_p(["dira/dirb"])
			FileUtils.touch(%w(fa .fa fa~ dira/dirb/b))
		end

		it "each() -> Enumerator" do
			Pa.each.should be_an_instance_of Enumerator
			Pa.each.with_object([]){|pa,m|m<<pa.b}.sort.should == %w(.fa dira fa fa~)
		end

		it "each(nodot: true) -> list all files except dot file" do
			Pa.each(nodot: true).with_object([]){|pa,m|m<<pa.b}.sort.should == %w(dira fa fa~)
		end

		it "each_r -> Enumerator" do
			Pa.each_r.should be_an_instance_of Enumerator
		 	Pa.each_r.with_object([]){|(pa,r),m|m<<r}.sort.should == %w(.fa dira dira/dirb dira/dirb/b fa fa~)
		end
	end


end
