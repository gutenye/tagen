require "spec_helper"

describe Array do
	describe "#first!" do
		it "runs ok" do
			a = [0, 1, 2]
			a.first!(2).should == [0, 1]
			a.should == [2]
		end
	end

	describe "#last!" do
		it "runs ok" do
			a = [0, 1, 2]
			a.last!(2).should == [1, 2]
			a.should == [0]
		end
	end

	describe "#find!" do
		it "runs ok" do
			a = [0, 1, 2]
			a.find!{|v| v==1}.should == 1
			a.should == [0,2]
		end
	end

	describe "#find_all!" do
		it "runs ok" do
			a = [0, 1, 2]
			a.find_all!{|v| v==0 or v ==2}.should == [0,2]
			a.should == [1]
		end
	end


end
