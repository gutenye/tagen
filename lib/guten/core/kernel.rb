# this file is extend Ruby built-in Things. 
#
# I use *o as function argument option.
#
# def guten *o
# 	o = o.to_o
# end
#
# guten :ok, :_ok  # convert to o[:ok]=true, o[:ok]=false
# 	:ok, :_ok is for Boolean
#
#	guten :age => 1 # convert to o[:age]=1
#		
#
#== Some change
#	alias :len :length for Array, String, ...
#
#
#

module Kernel #¤kernel
	private

	# same as ``, but add some options
	# @param [String] cmd a shell command
	# @param [Symbol, Hash] *o
	# 	@option [Boolean] :verbose
	def sh cmd, *o
		o = o.to_o
		echo cmd if o[:verbose]
		`#{cmd}`
	end

	# convert block to method.
	#   you can call a block with arguments
	#
	# @example USAGE
	#   instance_eval(&blk)
	#   blk2method(&blk).call *args
	def blk2method &blk
		self.class.class_eval do
			define_method(:__blk2method, &blk)
		end
		method(:__blk2method)
	end


	# detect Platform information.
	#   RUBY_PLATFORM is "i686-linux" "i386-migw32"
	def linux?; RUBY_PLATFORM=~/linux/ end  

	# @see #linux?
	def win32?; RUBY_PLATFORM=~/mingw32|mswin/ end 

		
	# print debug
	# like p, but use " " in each argument instead of "\n".
	#   p 1,2
	#    =>
	#     1
	#     2
	#   pd 1,2
	#    =>
	#     1 2
	def pd *args
		args.each do |arg| print arg.inspect," " end
		print "\n"
	end

end # module Kernel
