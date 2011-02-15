require_relative "string/format"
=begin
String.digits #=> "0123456789"
String.hexdigits = "01234567890ABCDEF" 
String.octdigits = "01234567" 
String.uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" 
String.lowercase = "abcdefghijklmnopqrstuvwxyz"
String.letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
=end

class String 
	@@didits = "0123456789" 
	@@hexdigits = "01234567890ABCDEF" 
	@@octdigits = "01234567" 
	@@uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ" 
	@@lowercase = "abcdefghijklmnopqrstuvwxyz"
	@@letters = @@uppercase + @@lowercase 
	class << self
		def digits; @@digits end
		def hexdigits; @@hexdigits end
		def octdigits; @@octdigits end
		def uppercase; @@uppercase end
		def lowercase; @@lowercase end
		def letters; @@letters end
	end
end # class String
