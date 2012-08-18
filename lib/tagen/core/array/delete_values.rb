class Array
  # Deletes items from self.
	#
	# @return [Array]
  # @see Array#delete
	def delete_values(*values, &blk)
		values.each.with_object([]) {|v,m|
			m << delete(v, &blk)
    }
	end

  # Deletes the element at the specified indexes.
	#
	# @return [Array] 
  # @see Array#delete_at
	def delete_values_at(*indexs, &blk)
		indexs.each.with_object([]) {|i,m|
			m << delete_at(i, &blk)
    }
	end
end
