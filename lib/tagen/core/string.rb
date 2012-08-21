class String
	# return ascii code
  #
	# @example
	#   'a'.ascii #=> 97
  #
	def ascii() 
    bytes.first 
  end
end

require "active_support/core_ext/string"
