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

require "active_support/time"
