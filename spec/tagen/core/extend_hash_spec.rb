require "spec_helper"
require "tagen/core/extend_hash"

class ExtendHash
  class << self
    public :deep_convert
  end
end

describe ExtendHash do
  describe ".deep_convert" do 
    it "convert string key to symbol key" do
      ExtendHash.deep_convert({"a" => 1, "b" => {"c" => 2}}).should == {a: 1, b: {c: 2}}
    end
  end

  describe ".[]" do
    it "convert Hash to ExtendHash with string key" do
      ret = ExtendHash[a: 1, "b" => 2]
      ret.should == {a: 1, b: 2}
    end
  end

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

