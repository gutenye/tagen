require "spec_helper"

describe Kernel do
  describe "#_tagen_wrap_cmd" do
    it do
      expect(_tagen_wrap_cmd("ls -l", true)).to eq("ls -l")
      expect(_tagen_wrap_cmd("ls -l", "$")).to eq("$ ls -l")
      expect(_tagen_wrap_cmd("ls -l", "#")).to eq("# ls -l")
    end
  end

  describe "#system" do
    it "" do
      should_receive(:system_without_tagen).with("foo -l", {})

      output = capture :stdout do
        system("foo -l", show_cmd: true)
      end

      expect(output).to eq("foo -l\n")
    end
  end

  describe "#sh" do
    it "" do
      should_receive(:`).with("foo -l")

      output = capture :stdout do
        sh("foo -l", show_cmd: true)
      end

      expect(output).to eq("foo -l\n")
    end
  end


end
