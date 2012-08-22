require "spec_helper"
require "tagen/erb"

describe ERB do
	describe "#result" do
		before :all do
			@erb = ERB.new("<%=a%>")
		end

		it "runs ok" do
			a = 1
			expect(@erb.result(binding)).to eq("1")
		end

		it "runs ok with local " do
			expect(@erb.result(nil, a: 2)).to eq("2")
		end

		it "support string as key in locals" do
			expect(@erb.result(nil, "a" => 2)).to eq("2")
		end
	end
end
