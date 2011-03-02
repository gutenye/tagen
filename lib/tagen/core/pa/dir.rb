module Pa::Dir
	# glob is * ** ? [set] {a,b}
	#
	# exclude '.' '..'
	#
	# @overload glob(*paths, o={})
	# 	@param [String] path
	# 	@param [Hash] o option
	# 	@option o [Boolean] :dot match dot file.
	# 	@return [Array<String>] 
	# @overload glob(*paths, o={})
	#   @yield [path] 
	#   @return [Array<string>]
	def glob(*args)
		paths, o = args.extract_options

		flag = 0
		flag |= File::FNM_DOTMATCH if o[:dot]

		files = paths.collect do |path|
			Dir.glob(path, flag)
		end
		files.flatten.tap{|v|v.delete(*%w(. ..))}
	end

	# is directory empty?
	#
	# @param [String] path
	# @return [Boolean]
	def empty?(path) Dir.entries(path).empty? end


	# traverse directory 
	# @note return if not a directory.
	#
	# @example
	#   each '.' do |pa|
	#     p pa.path
	#   end
	#   # => '/home' ..
	#
	# @overload each(path=".", o={})
	#   @param [String,Pa] path
	#   @prarm [Hash] o
	#   @option o [Boolean] :nodot (nil) include dot file
	#   @option o [Boolean] :nobackup (nil) include backup file
	#   @return [Enumerator]
	# @overload each(path=".", o={})
	#   @yield [path]
	#   @return [nil]
	def each(*args, &blk) 
		return Pa.to_enum(:each, *args) if not blk

		(path,), o = args.extract_options
		pa = Pa(path || ".")
		return if not pa.directory?

		Dir.foreach pa.p do |name|
			next if %w(. ..).include? name
			next if o[:nodot] and name=~/^\./
			next if o[:nobackup] and name=~/~$/

			blk.call(pa.join(name))
		end

		nil
	end

	# each with rescurive
	# @see each
	#
	# * each_r() skip Exception
	# * each_r(){pa, err}
	#
	# @overload each_r(path=".", o={})
	#   @return [Enumerator]
	# @overload each_r(path=".", o={})
	#   @yield [pa,err]
	#   @return [nil]
	def each_r(*args, &blk)
		return Pa.to_enum(:each_r, *args) if not blk

		(path,), o = args.extract_options
		path ||= "."

		_each_r(Pa(path), "", o, &blk)
	end

	def _each_r pa, relative, o, &blk
		each(pa, o) do |pa1|
			relative1 = Pa.join(relative, pa1.b) 
			blk.call pa1, relative1
			if pa1.directory?
				_each_r(pa1, relative1, o, &blk)
			end
		end
		rescue Errno::ENOENT, Errno::EPERM => e
			blk.call pa, relative, e 
	end
	private :_each_r

	# list directory contents
	# @see each
	#
	# @return [Array<String>]
	def ls(*args)
		each(*args).with_object([]){|pa,m| m<<pa.b}
	end

	# ls with rescurive
	# @see each
	#
	# @return [Array<String>]
	def ls_r(*args)
		each_r(*args).with_object([]){|pa,m| m<<pa.b}
	end
end
