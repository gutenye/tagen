require "spec_helper"

describe MatchData do
  describe "#to_hash" do
    it do
      expect("guten".match(/(?<a>.)(?<b>.)/).to_hash).to eq({a: "g", b: "u"})
    end
  end
end
