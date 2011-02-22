class Hash  
	alias :original_delete :delete
	# support delete more than one keys
	#   original: delete(key)
	#   current:  delete(*keys)
	def delete *keys, &blk
		values = keys.each.with_object [] do |k,m|
			m << original_delete(k, &blk)
		end
		keys.length==1 ? values[0] : values
	end

end # class Hash
