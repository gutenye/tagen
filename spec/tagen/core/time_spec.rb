require "spec_helper"

describe Time do
  describe ".time" do
    it do
      Time.stub_chain("now.to_f") { 1 }
      Time.time.should == 1
    end
  end
end

describe Numeric do
  describe "#time_humanize" do
    it do
      expect(36561906.time_humanize).to eq("1 years 2 months 3 days 4 hours 5 minutes")
      expect(0.time_humanize(true)).to eq("0 seconds")
    end
  end
end
