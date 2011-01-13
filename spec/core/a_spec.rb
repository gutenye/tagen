#!/usr/bin/rspec
require "guten/core"

class Guten; end

describe Ta do
	describe "test rc in Guten" do

		context "Rc not exists" do
			it "Rc.a is 1 " do
				Ta.rc Guten do
					a :a, 1
				end
				Guten::Rc.a.should == 1
			end
		end

		context "Rc already exists" do
			it "Rc.a is 2" do
				Ta.rc Guten do
					a :a, 2
				end
				Guten::Rc.a.should == 2
			end
		end

	end
end
