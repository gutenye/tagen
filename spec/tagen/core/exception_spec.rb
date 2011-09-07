require "spec_helper"
require "tagen/core/exception"

describe "Exception" do
  it "works with syntax 1" do
    MyError = Class.new Exception
    MyError.exit_code = 1

    MyError.new.exit_code.should == 1
  end

  it "works with syntax 2" do
    class MyError2 < Exception; @@exit_code = 1 end
    MyError2.new.exit_code.should == 1
  end

end

