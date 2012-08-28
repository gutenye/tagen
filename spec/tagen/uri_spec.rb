require "spec_helper"
require "tagen/uri"

describe URI::Generic do
  describe "#to_hash" do
    it do
      a = URI("http://example.com").to_hash
      b = { scheme: "http", userinfo: nil, host: "example.com", port: 80, path: "", query: nil, fragment: nil }

      expect(a).to eq(b)
    end
  end
end
