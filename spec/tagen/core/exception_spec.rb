require "spec_helper"

describe "Exception" do
  describe ".exit_code,=" do
    it do
      MyError = Class.new Exception
      MyError.exit_code = 1

      expect(MyError.new.exit_code).to eq(1)
    end
  end

  describe "@@exit_code" do
    it do
      class MyError2 < Exception 
        @@exit_code = 1 
      end

      expect(MyError2.new.exit_code).to eq(1)
    end
  end
end

