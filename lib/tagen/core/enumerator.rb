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
	def with_iobject(*args, &blk)
		return self.to_enum(:with_iobject, *args) unless blk

    (offset,), (memo,) = args.partition{|v| Fixnum === v}
    index = offset || 0
		raise ArgumentError, "must provide memo object" unless memo

		with_object(memo) do |args2, m|
			blk.call args2, index, m
      index += 1
		end
	end
end
