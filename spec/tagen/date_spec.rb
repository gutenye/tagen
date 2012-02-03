require "spec_helper"
require "tagen/date"

describe Date::Deta do
  before :all do
    Deta = Date::Deta
  end

  describe "#initialize" do
    it "works for 423 days" do
      d = Deta.new(423)
      d.years.should == 1
      d.months.should == 2
      d.days.should == 3
    end

    it "works for 32 days" do
      d = Deta.new(32)
      d.years.should == 0
      d.months.should == 1
      d.days.should == 2
    end

    it "works for 1 day" do
      d = Deta.new(1)
      d.years.should == 0
      d.months.should == 0
      d.days.should == 1
    end
  end

  describe "#display" do
    it "works for 1 years 2 months 3 days" do 
      d = Deta.new(1)
      d.stub(:years) { 1 }
      d.stub(:months) { 2 }
      d.stub(:days) { 3 }

      d.display.should == "1 years 2 months 3 days"
    end

    it "works for 2 months 3 days" do 
      d = Deta.new(1)
      d.stub(:years) { 0 }
      d.stub(:months) { 2 }
      d.stub(:days) { 3 }

      d.display.should == "2 months 3 days"
    end

    it "works for 0 days" do 
      d = Deta.new(1)
      d.stub(:years) { 0 }
      d.stub(:months) { 0 }
      d.stub(:days) { 0 }

      d.display.should == "0 days"
    end

    it "works for 0 days with :include_days => false" do 
      d = Deta.new(1)
      d.stub(:years) { 0 }
      d.stub(:months) { 0 }
      d.stub(:days) { 0 }

      d.display(false).should == ""
    end
  end

  describe "#to_a" do
    it "works" do
      d = Deta.new(1)
      d.stub(:years) { 1 }
      d.stub(:months) { 2 }
      d.stub(:days) { 3 }

      d.to_a.should == [ 1, 2, 3 ]
    end
  end

  describe ".deta" do
    it "works" do
      a = Deta.deta(Date.new(2011, 1, 2), Date.new(2011, 1, 1)).to_a
      b = [ 0, 0, 1 ]

      a.should == b
    end
  end
end

describe Time::Deta do
  before :all do
    Deta = Time::Deta
  end

  describe "#initialize" do
    it "works for 3723 seconds" do
      d = Deta.new(3723)
      d.hours.should == 1
      d.minutes.should == 2
      d.seconds.should == 3
    end

    it "works for 62 seconds" do
      d = Deta.new(62)
      d.hours.should == 0
      d.minutes.should == 1
      d.seconds.should == 2
    end

    it "works for 1 second" do
      d = Deta.new(1)
      d.hours.should == 0
      d.minutes.should == 0
      d.seconds.should == 1
    end
  end

  describe "#display" do
    it "works for 1 hours 2 minutes 3 seconds" do 
      d = Deta.new(1)
      d.stub(:hours) { 1 }
      d.stub(:minutes) { 2 }
      d.stub(:seconds) { 3 }

      d.display.should == "1 hours 2 minutes 3 seconds"
    end

    it "works for 2 minutes 3 seconds" do 
      d = Deta.new(1)
      d.stub(:hours) { 0 }
      d.stub(:minutes) { 2 }
      d.stub(:seconds) { 3 }

      d.display.should == "2 minutes 3 seconds"
    end

    it "works for 0 seconds" do 
      d = Deta.new(1)
      d.stub(:hours) { 0 }
      d.stub(:minutes) { 0 }
      d.stub(:seconds) { 0 }

      d.display.should == "0 seconds"
    end

    it "works for 0 seconds with :include_seconds => false" do 
      d = Deta.new(1)
      d.stub(:hours) { 0 }
      d.stub(:minutes) { 0 }
      d.stub(:seconds) { 0 }

      d.display(false).should == ""
    end
  end

  describe "#to_a" do
    it "works" do
      d = Deta.new(1)
      d.stub(:hours) { 1 }
      d.stub(:minutes) { 2 }
      d.stub(:seconds) { 3 }

      d.to_a.should == [ 1, 2, 3 ]
    end
  end

  describe ".deta" do
    it "works" do
      a = Deta.deta(Date.new(2011, 1, 2), Date.new(2011, 1, 1)).to_a
      b = [ 0, 0, 1 ]

      a.should == b
    end
  end
end

describe Date::Deta do
  before :all do
    Deta = DateTime::Deta
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
      a = Deta.deta(DateTime.new(2011, 1, 1, 1, 1, 2), DateTime.new(2011, 1, 1, 1, 1, 1)).to_a
      b = [ 0, 0, 0, 0, 0, 1 ]

      a.should == b
    end
  end
end
