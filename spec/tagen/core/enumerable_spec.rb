require "spec_helper"

describe Enumerable do
  describe "#grep_values" do
    it do
      expect(%w[ab ac bb cc].grep_values(/a./, /bb/)).to eq(%w[ab ac bb])
    end
  end
end
