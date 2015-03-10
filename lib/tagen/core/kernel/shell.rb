module Kernel
private

	# run `cmd` with :show_cmd option.
	#
	# @overload sh(cmd, o={})
	#   @param [String] cmd a shell command
	#   @param [Hash] o 
	#   @option o [Boolean] :show_cmd print cmd if true
	#   @return [String] result
  #
  # @see Kernel#`
	def sh(cmd, *args)
    o = args.last.instance_of?(Hash) ? args.pop : {}
    puts _tagen_wrap_cmd(cmd, o[:show_cmd]) if o[:show_cmd]
		`#{cmd}`
	end

	# Extends the default Kernel#system with :show_cmd option.
	#
	# @overload system([env,] command...[, options])
	#   @option options [Boolean] :show_cmd print cmd if true
  #
  # @see Kernel#system
	def system_with_tagen(*args)
    o = args.last.instance_of?(Hash) ? args.pop : {}
    if Hash === args[0] then
      env, *cmds = args
    else
      cmds = args
    end

    if o[:show_cmd]
      puts _tagen_wrap_cmd(cmds.join(" "), o[:show_cmd]) 
      o.delete(:show_cmd)
    end

    system_without_tagen *args, o
	end

  alias system_without_tagen system
  alias system system_with_tagen


  # @private
  def _tagen_wrap_cmd(cmd, pretty)
    case pretty
    when "$", "#"
      "#{pretty} #{cmd}"
    else
      cmd
    end
  end
end

$sudo = Process.pid != 0 && system("which sudo >/dev/null") ? "sudo" : ""
