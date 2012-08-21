require "spec_helper"

describe Kernel do
  def stub2(platform)
    RbConfig::CONFIG["host_os"] = platform
  end

  describe "#linux?" do
    it "is linux" do
      stub2("linux")
      expect(linux?).to be_true
    end

    it "is cygwin" do
      stub2("cygwin")
      expect(linux?).to be_true
    end
  end

  describe "#mac?" do
    it "is mac" do
      stub2("mac")
      expect(mac?).to be_true
    end

    it "is darwin" do
      stub2("darwin")
      expect(mac?).to be_true
    end
  end

  describe "#bsd?" do
    it "is bsd" do
      stub2("bsd")
      expect(bsd?).to be_true
    end
  end

  describe "#windows?" do
    it "is mswin" do
      stub2("mswin")
      expect(windows?).to be_true
    end

    it "is mingw" do
      stub2("mingw")
      expect(windows?).to be_true
    end
  end

  describe "#solaris?" do
    it "is solaris" do
      stub2("solaris")
      expect(solaris?).to be_true
    end

    it "is sunos" do
      stub2("sunos")
      expect(solaris?).to be_true
    end
  end

  describe "#symbian?" do
    it "is symbian" do
      stub2("symbian")
      expect(symbian?).to be_true
    end
  end

  describe "#posix?" do
    it "is linux" do
      stub2("linux")
      expect(posix?).to be_true
    end

    it "is mac" do
      stub2("mac")
      expect(posix?).to be_true
    end

    it "is bsd" do
      stub2("bsd")
      expect(posix?).to be_true
    end

    it "is solaris" do
      stub2("solaris")
      expect(posix?).to be_true
    end
  end
end

