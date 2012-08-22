require "spec_helper"

describe IO do
  describe ".append" do
    it do
      IO.should_receive(:write).with("foo", "content", nil, {mode: "a"})

      IO.append("foo", "content")
    end
  end
end

