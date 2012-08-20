class Time 
	# return a float of time since linux epoch
	#
	#   #=> 1295953427.0005338
	#
	# @return [Float] 
	def self.time 
    now.to_f 
  end

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

    # to [years, months, days, hours minutes seconds]
    def to_a
      [ years, months, days, hours, minutes, seconds ]
    end
  end
end

require "active_support/time"
