require "spec_helper"
require "tagen/pathname"

describe Pathname do
  describe "#path" do
    it do
      expect(Pathname.new("hello").path).to eq("hello")
    end
  end
end

