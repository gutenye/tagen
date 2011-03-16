require "spec_helper"
require "tagen/yaml"
require "tagen/core"
require "tmpdir"
require "fileutils"

describe YAML do
	before :all do
		@curdir = Dir.pwd
		@tmpdir = Dir.mktmpdir
		Dir.chdir @tmpdir
	end

	after :all do
		Dir.chdir @curdir
		FileUtils.rm_r @tmpdir
	end

	describe ".dump" do
		it "support Pa" do
			YAML.dump("foo", Pa('a'))
			File.read('a').should =~ /foo/ 
		end
	end

	describe ".load" do
		it "support Pa" do
			YAML.dump('foo', open('b', 'w+'))
			YAML.load(Pa('b')).should == 'foo'
		end
	end
end
