class Object
	def deepdup
		Marshal.load(Marshal.dump(self))
	end
end
