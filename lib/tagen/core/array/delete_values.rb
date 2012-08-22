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
  # @example
  #
  #  a = [1, 2, 3, 4]
  #  a.delete_values_at(0, 2)  -> [1, 3]
  #  a                         -> [2, 4]
  #
	# @return [Array] 
  # @see Array#delete_at
	def delete_values_at(*indexs, &blk)
    offset = 0

    # convert to positve index
    indexs.map { |i| i < 0 ? length + i : i }

		indexs.each.with_object([]) {|i,m|
      if i > length
        m << nil
      else
        m << delete_at(i-offset, &blk)
        offset += 1
      end
    }
	end
end
