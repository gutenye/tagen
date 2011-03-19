require "spec_helper"
require "tagen/erb"

describe ERB do
	describe "#result" do
		before :all do
			@erb = ERB.new("<%=a%>")
		end

		it "runs ok" do
			a = 1
			@erb.result(binding).should == "1"
		end

		it "runs ok with local " do
			@erb.result(nil, a: 2).should == "2"
		end

		it "support string as key in locals" do
			@erb.result(nil, "a" => 2).should == "2"
		end

	end
end
