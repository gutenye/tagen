module Kernel 
private

	# same as `` `` ``, but add some options
	#
	# @param [String] cmd a shell command
	# @param [Symbol, Hash] *o
	# @option o [Boolean] :verbose puts(cmd) to STDOUT
	def sh cmd, *o
		o = o.to_o
		puts cmd if o[:verbose]
		`#{cmd}`
	end

	# convert block to method.
	#
	#   you can call a block with arguments
	#
	# @example USAGE
	#   instance_eval(&blk)
	#   blk2method(&blk).call *args
	#
	def blk2method &blk
		self.class.class_eval do
			define_method(:__blk2method, &blk)
		end
		method(:__blk2method)
	end


	# detect Platform information.
	#
	#   RUBY_PLATFORM is "i686-linux" "i386-migw32"
	#
	# @return [Boolean]
	def linux?; RUBY_PLATFORM=~/linux/ end  

	# detect PLatform information.
	#
	# @return [Boolean]
	# @see {#linux?}
	def win32?; RUBY_PLATFORM=~/mingw32|mswin/ end 

		
	# *for debug* pd(print debug), search 'pd' is much easier than 'p' in a text-editor.
	#
	# like p, but use " " in each argument instead of "\n".
	#
	# @example
	#   p 1,2
	#    =>
	#     1
	#     2
	#   pd 1,2
	#    =>
	#     1 2
	#
	# @param [Object] *args
	# @return nil
	def pd *args
		args.each do |arg| print arg.inspect," " end
		print "\n"
	end

	# *for debug* print hr. puts '='*14 + " #{name}"
	#
	# sometime, we just need a horizonal line to separate message for debug.
	# @param [String] name
	def phr name=nil
		puts '='*14 + " #{name}"
	end

end # module Kernel
