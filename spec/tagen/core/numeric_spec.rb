require "spec_helper"

describe Numeric do
  describe "#div2" do
    it do
      expect(3.div2(2)).to eq(2)
      expect(4.div2(2)).to eq(2)
    end
  end
end
