require "spec_helper"

describe Process do
  describe ".exists?" do
    it do
      if linux?
        expect(Process.exists?(Process.pid)).to be_true
        expect(Process.exists?(-1)).to be_false
      else
        expect{ Process.exists?(Process.pid) }.to raise_error(NotImplementedError)
      end
    end
  end
end
