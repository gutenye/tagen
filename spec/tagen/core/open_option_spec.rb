require "spec_helper"

describe OpenOption do
	before :each do
		@o = OpenOption.new a: 1, force: true
	end

	it "runs ok" do
		@o._data.should == {a: 1, force: true}
	end



	it "read value using [:sym] " do
		@o[:a].should == 1
	end

	it "read value using ['str'] " do
		@o['a'].should == 1
	end

	it "read value using #key" do
		@o.a.should == 1
	end

	it "read value using #key?" do
		@o.force?.should be_true
	end

	it "return nil if no key" do
		@o[:key_not_exists].should be_nil
	end

	it "write value using [:sym]=" do
		@o[:b] = 2
		@o._data[:b].should == 2
	end

	it "write value using ['key']=" do
		@o['b'] = 3
		@o._data[:b].should == 3
	end

	it "write value using #key=" do
		@o.b = 4
		@o._data[:b].should == 4
	end

	it "#_merge" do
		o = @o._merge(a: 2)
		o._data[:a].should == 2
	end

	it "#_merge!" do
		@o._merge!(a: 2)
		@o._data[:a].should == 2
	end

	it "#_replace runs ok" do
		@o._replace ({b: 2})
		@o._data.should == {b: 2}
	end

	it "support normal hash method" do
		@o._keys.should == [:a, :force]
	end

	describe ".convert_hash" do
		it "deep convert hash" do
			data = {a: {b: 1} }
			newdata = OpenOption.convert_hash(data)
			newdata[:a].should be_an_instance_of OpenOption
		end



	end

end
