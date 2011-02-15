class Array
	# extend options are symbols and hash, symbol as a boolean option.
	#   :a #=> { a: true }
	#   :_a #=> { a: false}
	#
	#   def foo(*args)
	#     options = args.extract_extend_options!
	#   end
	#
	#   foo(1, :a, :_b, :c => 2) #=> {a: true, b: false, c: 2}
	#   
	# @see extract_options!
	def extract_extend_options! *defaults
		o1 = _parse_o(defaults)
		o2 = _parse_o(self)
		o1.merge o2
	end

	private
	def _parse_o obj
		case obj
		when Array
			# name:1
			o1 = Hash === obj.last ? obj.pop : {}
			# :force :_force
			rst = obj.find_all!{|v| Symbol===v}
			o2={}
			rst.each do |k|
				v = true
				if k=~/^_/
					k = k[1..-1].to_sym
					v = false
				end
				o2[k] = v
			end
			o1.merge o2
		when Hash
			obj
		end
	end

	# Extracts options from a set of arguments. Removes and returns the last
	# element in the array if it's a hash, otherwise returns a blank hash.
	# you can also pass a default option.
	#
	#   def options(*args)
	#     o = args.extract_options!(:a=>1)
	#   end
	#
	#   options(1, 2)           # => {:a=>1}
	#   options(1, 2, :a => :b) # => {:a=>:b}
	#
	def extract_options! default={}
		if self.last.is_a?(Hash) && self.last.instance_of?(Hash)
			self.pop.merge default
		else
			default
		end
	end
end
