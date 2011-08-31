require "spec_helper"
require "tagen/core/extend_hash"

describe ExtendHash do
  describe "#[]" do
    it "convert string-key to symbol-key" do
      h = ExtendHash.new
      h.store(:ok, 1)
      h["ok"].should == 1
    end
  end

  describe "#[]=" do
    it "convert string-key to symbol-key" do
      h = ExtendHash.new
      h["ok"] = 1
      h[:ok] = 1
    end
  end

  describe "#method_missing" do
    it "#key" do
      h = ExtendHash.new
      h[:ok] = 1
      h.ok.should == 1
    end

    it "#key=" do
      h = ExtendHash.new
      h.ok = 1
      h.ok.should == 1
    end
  end
end

