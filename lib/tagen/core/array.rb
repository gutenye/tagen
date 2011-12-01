require_relative "array/extract_options"
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


	# first n values, not works at Range, Range don't have #replace method
	# @note modify IN PLACE
	#
	# @example
	#   a = %w(1 2 3)
	#   a.first!(2)  #=> [1, 2]
	#   a            #=> [3]
	#   @return Array
	def first! n=1
		i = 0 
		j = i + n
		k = -1

		ret = self[i...j]
		self.replace self[j..k]
		ret
	end

	# last n values
	# @see first!
	def last! n=1
		i = -1 
		j = -1 - n + 1
		k = 0

		ret = self[j..i]
		self.replace self[k...j]
		ret
	end



	# same as find, but delete the finded value 
	def find! &blk
		idx = self.find_index(&blk)
		if idx
			self.delete_at(idx)
		else
			nil
		end
	end

	# same as find_all, but delete all finded values
	def find_all! &blk
		ret, rest = [], []
		self.each do |k|
			if blk.call(k)
				ret << k
			else
				rest << k
			end
		end
		self.replace rest
		ret
	end

  alias original_grep grep

  # confict with awesome_print which extend grep, too
  # add grep(arr rb/tage)
  #def grep(pat_s, &blk)
    #pats = Array===pat_s ? pat_s : [pat_s]
    #pats.each.with_object([]) { |k, memo|
      #memo.push *self.original_grep(k)
    #}
  #end

end # class Array
