require "spec_helper"

describe Time do
  describe ".time" do
    it "works" do
      Time.stub_chain("now.to_f") { 1 }
      Time.time.should == 1
    end
  end
end

describe Time::Deta do
  before :all do
    Object.send :remove_const, :Deta if Object.const_defined?(:Deta)
    Deta = Time::Deta
  end

  describe "#initialize" do
    it "works for 36561906 seconds" do
      d = Deta.new(36561906)

      d.years.should == 1
      d.months.should == 2
      d.days.should == 3
      d.hours.should == 4
      d.minutes.should == 5
      d.seconds.should == 6
    end
  end

  describe "#display" do
    it "works for 1 years 2 months 3 days 4 hours 5 minutes 6 seconds" do 
      d = Deta.new(36561906)

      d.display.should == "1 years 2 months 3 days 4 hours 5 minutes 6 seconds"
    end

    it "works for 0 second" do
      d = Deta.new(0)

      d.display.should == "0 seconds"
    end
  end

  describe "#to_a" do
    it "works" do
      d = Deta.new(1)
      d.stub(:years) { 1 }
      d.stub(:months) { 2 }
      d.stub(:days) { 3 }
      d.stub(:hours) { 4 }
      d.stub(:minutes) { 5 }
      d.stub(:seconds) { 6 }


      d.to_a.should == [ 1, 2, 3, 4, 5, 6 ]
    end
  end

  describe ".deta" do
    it "works" do
      a = Deta.deta(Time.new(2011, 1, 1, 1, 1, 2), Time.new(2011, 1, 1, 1, 1, 1)).to_a
      b = [ 0, 0, 0, 0, 0, 1 ]

      a.should == b
    end
  end
end
