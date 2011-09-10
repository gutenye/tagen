class Module 
	# return hash instead of names
	# @see constants
	# 
	# @return [Hash] {key: value}
	def consts
		constants.each.with_object ({}) do |k,m|
			m[k] = const_get(k)
		end
	end
end #class Module
