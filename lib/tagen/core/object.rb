class Object
	# default \#dup is shallow. 
	#
	# @example
	# 	# dup
	# 	a={a: { b: 1 }}
	# 	a2 = a.dup
	# 	a2[:a][:b] = 2
	# 	p a  #=> {a: {b: 2} }
	#
	# 	# use deepdup
	# 	a= {a: {b: 1 }}
	# 	a2 = a.deepdup
	# 	a2[:a][:b] = 2
	# 	p a #=> {a: {b: 1}}
	#
	# @return [Object]
	def deepdup
		Marshal.load(Marshal.dump(self))
	end
end
