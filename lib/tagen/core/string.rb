class String
	# Return first character's ascii code.
  #
	# @example
  #
	#   'a'.ascii     -> 97
  #
	def ascii() 
    bytes.first 
  end
end

Require "active_support/core_ext/string"
