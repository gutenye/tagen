require "spec_helper"
require "tagen/rbconfig"

describe RbConfig do
  describe ".method_missing" do
    it do
      expect(RbConfig["host_os"]).to eq(RbConfig::CONFIG["host_os"])
    end
  end
end

