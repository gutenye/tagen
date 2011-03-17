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

	describe "#==" do
		it "runs ok" do
			(Pa('/home') == Pa('/home')).should be_true
		end
	end

	describe "#+" do
		it "runs ok" do
			(Pa('/home')+'~').should == Pa('/home~')
		end
	end

	describe "#sub" do
		it "runs ok" do
			Pa('/home/foo').sub(/o/,'').should == Pa('/hme/foo')
		end
	end

	describe "#sub!" do
		it "runs ok" do
			pa = Pa('/home/foo')
			pa.sub!(/o/,'')
			pa.should == Pa('/hme/foo')
		end
	end

	describe "#gsub" do
		it "runs ok" do
			Pa('/home/foo').gsub(/o/,'').should == Pa('/hme/f')
		end
	end

	describe "#gsub!" do
		it "runs ok" do
			pa = Pa('/home/foo')
			pa.gsub!(/o/,'')
			pa.should == Pa('/hme/f')
		end
	end

	describe "#match" do
		it "runs ok" do
			Pa('/home/foo').match(/foo/)[0].should == 'foo'
		end
	end

	describe "#start_with?" do
		it "runs ok" do
			Pa('/home/foo').start_with?('/home').should be_true
		end
	end

	describe "#end_with?" do
		it "runs ok" do
			Pa('/home/foo').end_with?('foo').should be_true
		end
	end

	describe "#=~" do
		it "runs ok" do
			(Pa('/home/foo') =~ /foo/).should be_true
		end
	end


end
