require "spec_helper"

describe Enumerable do
  describe "#grep_values" do
    expect(%w[ab ac bb cc].grep_values(/a./, /bb/)).to eq(%w[aa ac bb])
  end
end
