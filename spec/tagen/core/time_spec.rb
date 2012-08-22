require "spec_helper"

describe Time do
  describe ".time" do
    it do
      Time.stub_chain("now.to_f") { 1 }
      Time.time.should == 1
    end
  end
end
