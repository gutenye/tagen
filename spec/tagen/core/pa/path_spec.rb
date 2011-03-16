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

	describe "NAME_EXT_PAT" do
		it "matchs `foo.bar'" do
			"foo.bar".match(Pa::NAME_EXT_PAT).captures.should == %w(foo bar)
		end

		it "matchs `foo'" do
			"foo".match(Pa::NAME_EXT_PAT).captures.should == ["foo", nil]
		end

	end

	describe "basename" do
		it "get a basename of a path" do
			Pa.basename("/home/foo").should == "foo"
		end

		it "get name, ext with :ext => true" do
			Pa.basename("/home/foo.bar", ext: true).should == ["foo", "bar"]
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
