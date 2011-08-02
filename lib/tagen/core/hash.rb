class Hash  
	alias :original_delete :delete

	# support delete more than one keys
	#
	#   original: delete(key)
	#   current:  delete(*keys)
	#
	# return [Hash]
	def delete *keys, &blk
		values = keys.each.with_object [] do |k,m|
			m << original_delete(k, &blk)
		end
		keys.length==1 ? values[0] : values
	end


  # grep pat at hash's keys, and return a new hash.
  # @see Array#grep
  #
  # @example
  #
  #  foo = {a: 1, b: 2}
  #  foo.grep(:a) #=> {a: 1}
  #
  # @return [Hash]
  def grep(pat)
    filter_keys = keys.grep(pat)
    filter_keys.each.with_object({}) { |k,memo|
      memo[k] = self[k]
    }
  end
end # class Hash
