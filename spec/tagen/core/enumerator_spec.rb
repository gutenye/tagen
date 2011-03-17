require "spec_helper"

describe Enumerator do
	describe "#with_iobject" do

		it "support mem_obj" do
			ret = [1,2].each.with_iobject [] do |v,i, m|
				m << v
			end
			ret.should == [1,2]
		end

		it "support offset" do
			ret = [1,2].each.with_iobject 2, [] do |v,i, m|
				m << i
			end
			ret.should == [2,3]
		end

	end
end
