require "spec_helper"

describe Module do 
	describe "#consts" do
		it "runs ok" do
			module Constants
				A = 1
			end

			Constants.consts.should == {A: 1}

		end
	end
end
