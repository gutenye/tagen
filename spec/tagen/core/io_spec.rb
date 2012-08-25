require "spec_helper"

describe IO do
  describe ".write" do
    it do
      IO.should_receive(:write_without_tagen).with("foo", "content", nil, {mkdir: true})

      IO.write("foo", "content", mkdir: true)
    end
  end

  describe ".append" do
    it do
      IO.should_receive(:write).with("foo", "content", nil, {mode: "a"})

      IO.append("foo", "content")
    end
  end
end

