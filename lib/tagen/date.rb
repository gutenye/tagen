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

    attr_reader :years, :months, :days, :hours, :minutes, :seconds

    def initialize(seconds)
      deta = seconds
      deta, @seconds = deta.divmod(60)
      deta, @minutes = deta.divmod(60)
      deta, @hours = deta.divmod(24)
      deta, @days = deta.divmod(30)
      @years, @months = deta.divmod(12)
    end

    def display(include_seconds=true)
      ret = ""
      ret << "#{years} years " unless years == 0
      ret << "#{months} months " unless months == 0
      ret << "#{days} days " unless days==0
      ret << "#{hours} hours " unless hours == 0
      ret << "#{minutes} minutes " unless minutes == 0
      ret << "#{seconds} seconds" if include_seconds

      ret
    end

    # to [years, months, days, hours, minutes, seconds]
    def to_a
      [ years, months, days, hours, minutes, seconds ]
    end
  end
end
