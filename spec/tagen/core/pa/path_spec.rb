require "spec_helper"

describe Pa do
	describe ".shorten" do
		it "short /home/usr/file into ~/file" do
			ENV["HOME"] = "/home/foo"
			Pa.shorten("/home/foo/file").should == "~/file"
		end

		it "not short /home/other-user/file" do
			ENV["HOME"] = "/home/foo"
			Pa.shorten("/home/bar/file").should == "/home/bar/file"
		end
	end

	describe "#short" do
		it "return a short path" do
			ENV["HOME"] = "/home/foo"
			Pa("/home/bar/file").short == "~/file"
		end
	end

end
