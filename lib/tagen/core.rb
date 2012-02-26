require "pd"

# from core
%w(
	core/kernel
	core/object
	core/module

	core/enumerable
	core/enumerator
	core/numeric
	core/string
	core/array
	core/hash
	core/extend_hash
	core/re

	core/time
	core/io
	core/process

	core/open_option
).each {|n| require_relative n }

# from active_support
require "active_support/core_ext"
