class Module 

	alias :original_append_features :append_features

	# after include module, convert methods in  ClassMethods to class methods.
	# @see ruby-core Module#append_features
	#
	# @example
	#   module Guten
	#   	module ClassMethods
	#   		def foo; end     # after include Guten, method 'foo' becomes a class method.
	#   	end
	#	  end
	#  
	#   class Tag
	#   	include Guten
	#	  end
	#	  Tag.foo
	#
	def append_features base
		original_append_features base
		base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)
	end

end #class Module
