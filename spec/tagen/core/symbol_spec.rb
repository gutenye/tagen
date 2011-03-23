require "spec_helper"

describe Symbol do
	describe "#method_missing" do
		it "#sub. returns a symbol" do
			:_foo.sub(/_/, '').should == :foo
		end

		it "#chars. return a enumerator" do
			:_foo.chars.should be_an_instance_of Enumerator
		end
		
	end
end
