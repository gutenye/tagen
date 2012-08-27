class Time 
	# Return a float of time since linux epoch
	#
  # @example
  #
	#   Time.time     -> 1295953427.0005338
	#
	# @return [Float] 
	def self.time 
    now.to_f 
  end
end

class Numeric
  # Reports the approximate distance in time between two Time, Date or DateTime objects or integers as seconds.
  #
  # @example
  #
  #   1.time_humanize(true)    -> 1 seconds
  #   36561906.time_humanize   -> 1 years 2 months 3 days 4 hours 5 minutes
  #
  def time_humanize(include_seconds=false)
    deta = self
    deta, seconds = deta.divmod(60)
    deta, minutes = deta.divmod(60)
    deta, hours = deta.divmod(24)
    deta, days = deta.divmod(30)
    years, months = deta.divmod(12)

    ret = ""
    ret << "#{years} years " unless years == 0
    ret << "#{months} months " unless months == 0
    ret << "#{days} days " unless days == 0
    ret << "#{hours} hours " unless hours == 0
    ret << "#{minutes} minutes " unless minutes == 0
    ret << "#{seconds} seconds" if include_seconds

    ret.rstrip
  end
end

require "active_support/time"
