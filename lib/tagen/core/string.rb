class String 
	@@didits = "0123456789" 
	@@hexdigits = "01234567890ABCDEF" 
	@@octdigits = "01234567" 
	@@uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" 
	@@lowercase = "abcdefghijklmnopqrstuvwxyz"
	@@letters = @@uppercase + @@lowercase 

	class << self

		# "0123456789"
		#
		# @return [String]
		def digits; @@digits end

		# "01234567890ABCDEF" 
		#
		# @return [String]
		def hexdigits; @@hexdigits end

		# "01234567" 
		#
		# @return [String]
		def octdigits; @@octdigits end

		# "ABCDEFGHIJKLMNOPQRSTUVWXYZ" 
		#
		# @return [String]
		def uppercase; @@uppercase end

		# "abcdefghijklmnopqrstuvwxyz"
		#
		# @return [String]
		def lowercase; @@lowercase end

		# "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
		#
		# @return [String]
		def letters; @@letters end
	end
end # class String

require_relative "string/pyformat"
