class Module 

	alias :original_append_features :append_features

	# after include module, convert methods in ClassMethods to class methods. a very clean design.
	# @see ruby-core Module#append_features
	#
	# @example
	#   module Guten
	#   	module ClassMethods
	#   		def foo; end      # this is class method.
	#   	end
	#
	#    def bar; end # this is instance method. 
	#	  end
	#  
	#   class Tag
	#   	include Guten  # will auto Tag.extend(Guten::Classmethods)
	#	  end
	#
	def append_features base
		original_append_features base
		base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)
	end

	# return hash instead of names
	# @see constants
	# 
	# @return [Hash] {key: value}
	def consts
		constants.each.with_object ({}) do |k,m|
			m[k] = const_get(k)
		end
	end

end #class Module
