class Socket
class <<self
	# pack human-readable address to Socket address
	#
	# @example
	# 	addr("192.168.1.1") #=> "\xC0\xA8\x01\x01"
	#
	# @return [String] address used by Socket
	# @see unaddr
	def addr(str) str.split(".").map{|v|v.to_i}.pack("CCCC") end

	# unpack to humna-readable address from  Socket address 
	#
	# @example
	# 	unaddr("\xC0\xA8\x01\x01") #=> "192.168.1.1"
	#
	# @return [String] human readable address
	def unaddr(str) str.unpack("CCCC").join(".") end
end
end
