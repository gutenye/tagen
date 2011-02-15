#!/usr/bin/rspec
require "bundler/setup"
require "guten/core"
require "guten/core/pa"

describe Pa do
	describe "#glob_s" do
		it "prints a lot" do
			puts Pa.glob_s("/mnt/*")
		end
	end

	describe "#mv" do

	end

	describe "#ls" do
		puts Pa.ls("/")
	end

end
