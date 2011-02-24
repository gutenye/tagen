module Marshal 
class <<self

	alias :original_load :load

	# add support with Pa
	#
	#   Marshal.load(Pa(path))
	#
	# @param [IO,String,Pa] obj
	# @return [String]
	def load(obj) original_load Pa===obj ? File.read(obj.p) : obj end

	alias :original_dump :dump

	# add support with Pa
	#
	#   Marshal.dump(obj, Pa(path))
	#   dump(con, [obj], limit=-1)
	#
	# @param [String,Pa] obj
	# @return [String]
	def dump(obj, *args)
		case args[0]
		when String, Pa
			path = String===args[0] ? args[0] : args[0].p
			open(path, "wb"){|f| f.write(original_dump(con))}
		else
			original_dump con, *args
		end
	end

end
end
