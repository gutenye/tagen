require "spec_helper"

describe Array do
	describe "#extract_options" do
		it "returns [args, option]" do
			args = [1, a:1, b:2]
			nums, o = args.extract_options 
			nums.should == [1]
			o.should == {a:1, b:2}
			args.should == [1, a:1, b:2]
		end
	end

	describe "#extract_options!" do
		it "returns option" do
			args = [1, a:1, b:2]
			o = args.extract_options!
			o.should == {a:1, b:2}
			args.should == [1]
		end
	end

	describe "#extract_extend_options" do

		it "returns [args, option]" do
			args = [1, :a, :_b, c:2]
			nums, o = args.extract_extend_options 
			nums.should == [1]
			o.should == {a:true, b:false, c:2}
			args.should == [1, :a, :_b, c:2]
		end
	end

	describe "#extract_extend_options!" do
		it "modify args and returns option only" do
			args = [1, :a, :_b, c:2]
			o = args.extract_extend_options!
			args.should == [1]
			o.should == {a:true, b:false, c:2}
		end
	end
end
