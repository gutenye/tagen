require "date"

class Date # ::Deta
  class Deta
    class <<self
      # @param [Date] from
      # @param [Date] to
      # @return [Date::Deta] deta
      def deta(from, to)
        days = (from-to).to_i
        self.new(days)
      end
    end

    attr_reader :years, :months, :days

    def initialize(days)
      deta = days
      deta, @days = deta.divmod(30)
      @years, @months = deta.divmod(12)
    end

    def display(include_days=true)
      ret = ""
      ret << "#{years} years " unless years == 0
      ret << "#{months} months " unless months == 0
      ret << "#{days} days" unless (!include_days && days==0)

      ret
    end

    # to [years months days]
    def to_a
      [ years, months, days ]
    end
  end
end

class Time # ::Deta
  class Deta
    class <<self
      # @param [Time] from
      # @param [Time] to
      # @return [Time::Deta] deta
      def deta(from, to)
        seconds = (from-to).to_i
        self.new(seconds)
      end
    end

    attr_reader :hours, :minutes, :seconds

    def initialize(seconds)
      deta = seconds
      deta, @seconds = deta.divmod(60)
      @hours, @minutes = deta.divmod(60)
    end

    def display(include_times=true)
      ret = ""
      ret << "#{hours} hours " unless hours == 0
      ret << "#{minutes} minutes " unless minutes == 0
      ret << "#{seconds} seconds" unless (!include_times && seconds==0)

      ret
    end

    # to [hours minutes seconds]
    def to_a
      [ hours, minutes, seconds ]
    end
  end
end

class DateTime # ::Deta
  class Deta
    class <<self
      # @param [DateTime] from
      # @param [DateTime] to
      # @return [DateTime::Deta] deta
      def deta(from, to)
        seconds = (from-to)*24*3600.to_i
        self.new(seconds)
      end
    end

    attr_reader :date, :time, :years, :months, :days, :hours, :minutes, :seconds

    def initialize(seconds)
      days, seconds = seconds.divmod(86400)

      @date = Date::Deta.new(days)
      @time = Time::Deta.new(seconds)

      @years = @date.years
      @months = @date.months
      @days = @date.days
      @hours = @time.hours
      @minutes = @time.minutes
      @seconds = @time.seconds
    end

    def display
      ret = ""
      ret << "#{@date.display(false)} " unless @date.days == 0
      ret << @time.display

      ret
    end

    # to [years, months, days, hours, minutes, seconds]
    def to_a
      [ years, months, days, hours, minutes, seconds ]
    end
  end
end


