class Enumerator
	# combine with_index and with_object
	# @see with_index, with_object
	#
	# @example
	#   (1..7).each.with_iobject([]){|(*args), idx, memo|}
	#   (1..7).each.with_iobject(2, []){|(*args), idx, memo|} # offset is 2
	#
	# @overload with_iobject(*args)
	#   @param [Fixnum,Object] *args pass Fixnum as offset, otherwise as memo_obj
	#   @return Enumerator
	#
	# @overload with_iobject(*args)
	#   @yieldparam [Object] (*args)
	#   @yieldparam [Fixnum] idx index
	#   @yieldparam [Object] memo_obj 
	def with_iobject *args, &blk
		return self.to_enum(:with_iobject, *args) unless blk

		offset = args.find!{|v| Fixnum==v} or 0
		raise ArgumentError "must provide memo_obj" if args.empty?
		memo = args[0]

		i = offset-1
		self.with_object memo do |args, m|
			blk.call args,i+=1,m
		end
	end
end
