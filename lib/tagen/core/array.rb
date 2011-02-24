=begin
Additional method list
----------------------

* `#append` _alias from push_

=end
class Array  
	alias append push

	alias original_delete delete

	# support delete more than one values.
	#
	# 	original: delete(v)
	# 	currrent: delete(*v)
	#
	# @return [Array]
	def delete *values, &blk
		indexs = values.each.with_object [] do |v,m|
			m << original_delete(v, &blk)
		end
		values.length==1 ? indexs[0] : indexs
	end

	alias original_delete_at delete_at

	# support delate_at more than one index.
	#
	# 	original: delete_at(i)
	# 	current: delte_at(*i)
	#
	# @return [Array] 
	def delete_at *indexs, &blk
		values = indexs.each.with_object [] do |i,m|
			m << original_delete_at(i, &blk)
		end
		indexs.length==1 ? values[0] : values
	end
end # class Array
