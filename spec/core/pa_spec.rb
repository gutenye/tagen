#!/usr/bin/rspec
require "bundler/setup"
require "guten/core"
require "guten/core/pa"

describe Pa do
	describe "#glob_s" do
		it "print a lot" do
			puts Pa.glob_s("/mnt/*")
		end
	end
end
