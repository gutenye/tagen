class Symbol

	# goes to String, return Symbol
	def method_missing name, *args
		ret = to_s.send name, *args
		String===ret ? ret.to_sym : ret
	end

end