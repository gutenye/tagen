require "spec_helper"

describe String do
  describe "#ascii" do
    it do
      expect("a".ascii).to eq(97)
    end
  end
end
