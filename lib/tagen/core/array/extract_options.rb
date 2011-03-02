class Array
	# Extracts options from a set of arguments. Removes and returns the last
	# element in the array if it's a hash, otherwise returns a blank hash.
	# you can also pass a default option.
	#
	# @example
	#   def options(*args)
	#     o = args.extract_options!(:a=>1)
	#   end
	#
	#   options(1, 2)           # => {:a=>1}
	#   options(1, 2, :a => :b) # => {:a=>:b}
	#
	# @param [Hash] default default options
	# @return [Hash]
	def extract_options! default={}
		if self.last.is_a?(Hash) && self.last.instance_of?(Hash)
			self.pop.merge default
		else
			default
		end
	end

	# extract options
	# @see extract_options!
	# @example
	#   def mkdir(*args)
	#     paths, o = args.extract_options
	#   end
	#
	# @return [Array<Array,Hash>] 
	def extract_options default={}
		if self.last.is_a?(Hash) && self.last.instance_of?(Hash)
			[self[0...-1], self[-1].merge(default)]
		else
			[self, default]
		end
	end

end
