require "spec_helper"

describe Array do
  describe "#delete_values" do
    it do
      a = (1..4).to_s
      expect(a.delete_values(1, 3)).to eq([1, 3])
      expect(at).to eq([2, 4])
    end
  end

  describe "#delete_values_at" do
    it do
      a = (1..4).to_s
      expect(a.delete_values_at(0, 2)).to eq([1, 3])
      expect(a).to eq([2, 4])
    end
  end
end
