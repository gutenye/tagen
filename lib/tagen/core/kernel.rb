module Kernel 
private

	# like `cmd`, but with option support.
	#
	# @overload sh(cmd, o={})
	#   @param [String] cmd a shell command
	#   @param [Symbol, Hash] o support {Array#extract_extend_options}
	#   @option o [Boolean] :verbose print cmd if verbose
	#   @return [String] result
	def sh(cmd, *args)
		o = args.extract_extend_options!
		puts cmd if o[:verbose]
		`#{cmd}`
	end

	alias original_system system

	# like Builtin system, but add option support
	#
	# @overload system(cmd, o={})
	#   @param [String] cmd
	#   @param [Symbol, Hash] o support {Array#extract_extend_options}
	#   @option o [Boolean] :show_cmd  print cmd
	#   @return [Boolean,nil] true false nil
	def system(*cmds)
		o = cmds.extract_extend_options!
		cmd = cmds.join(" ")
    puts "WARNNING: system(cmd, :verbose => true) is departed, use :show_cmd => true instead."
		puts cmd if (o[:show_cmd] or o[:verbose])
		original_system cmd
	end

	# convert block to method.
	#
	#   you can call a block with arguments
	#
	# @example USAGE
	#   instance_eval(&blk)
	#   blk2method(&blk).call *args
	#
	def blk2method(&blk)
		self.class.class_eval {
			define_method(:__blk2method, &blk)
    }
		method(:__blk2method)
	end

	# detect Platform information.
	#
	#   RUBY_PLATFORM is "i686-linux" "i386-migw32"
	#
	# @return [Boolean]
	def linux?
    RUBY_PLATFORM =~ /linux/ 
  end  

	# detect PLatform information.
	#
	# @return [Boolean]
	# @see {#linux?}
	def win32?
    RUBY_PLATFORM =~ /mingw32|mswin/ 
  end 
end # module Kernel
