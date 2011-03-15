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

	describe '.parent' do
		before :each do
			@path = "/home/foo/a.txt"
		end

		it "return parent path" do
			Pa.parent(@path).should == "/home/foo"
		end

		it "return parent upto 2 level path" do
			Pa.parent(@path, 2).should == "/home"
		end
	end

end
