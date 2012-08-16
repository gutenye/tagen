module Kernel 
private

	# like `cmd`, but with option support.
	#
	# @overload sh(cmd, o={})
	#   @param [String] cmd a shell command
	#   @param [Symbol, Hash] o support {Array#extract_extend_options}
	#   @option o [Boolean] :show_cmd print cmd if true
	#   @return [String] result
  #
  # @see Kernel#`
	def sh(cmd, *args)
		o = args.extract_extend_options!
		puts cmd if o[:show_cmd]
		`#{cmd}`
	end

  if !defined?(tagen_original_system) then
    alias tagen_original_system system
  end

	# like Builtin system, but add option support
	#
	# @overload system([env,] command...[, options])
	#   @option options [Boolean] :show_cmd print cmd if true
  #
  # @see Kernel#system
	def system(*args)
		o = args.extract_extend_options!
    if Hash === args[0] then
      env, *cmds = args
    else
      cmds = args
    end

    if o[:show_cmd]
      puts cmds.join(" ") 
      o.delete(:show_cmd)
    end

		tagen_original_system *args, o
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
