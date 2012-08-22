require "active_support/core_ext/array/extract_options"

class Array
  # Extracts options from a set of arguments. 
  #
	# @example
  #
  #   dirs, o = ["foo", "bar", {a: 1}].extract_options(b: 2)  
  #     -> ["foo", "bar"], {a: 1, b: 2}
  #
  #   (dir,), o = ["foo", {a: 1}].extract_options 
  #     -> "foo", {a: 1}
  #
	# @return [Array<Array,Hash>] 
	# @see extract_options!
	def extract_options(default={})
    if last.is_a?(Hash) && last.extractable_options?
			[self[0...-1], default.merge(self[-1])]
		else
			[self, default]
		end
	end

  # Extracts options from a set of arguments. Removes and returns the last
  # element in the array if it's a hash, otherwise returns a blank hash.
  #
  # @example
  #
  #   def options(*args)
  #     args.extract_options!(a: 1)
  #   end
  #
  #   options(1, 2)            -> {a: 1}
  #   options(1, 2, a: 2)      -> {a: 2}
	#
	# @param [Hash] default default options
	# @return [Hash]
	def extract_options!(default={})
    if last.is_a?(Hash) && last.extractable_options?
      default.merge pop
    else
      default
    end
	end
end
