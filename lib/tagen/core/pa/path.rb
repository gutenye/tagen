module Pa::Path

	# extname of a path
	#
	# @example
	# 	"a.ogg" => "ogg"
	# 	"a" => nil
	#
	# @param [String] path
	# @return [String]
	def extname path
		_, ext = path.match(/\.([^.]+)$/).to_a
		ext
	end

	# is path an absolute path ?
	#
	# @param [String] path
	# @return [Boolean]
	def absolute?(path) absolute(path) == path end

	# get a basename of a path
	#
	# @param [String] name
	# @param [Hash] o options
	# @option o [Boolean, String] :ext (false) return \[name, ext] if true
	#   
	# @return [String] basename of a path 
	# @return [Array<String,String>] \[name, ext] if o[:ext] is true
	def basename(name, o={})
		name = super(name)
		if o[:ext]
			_, name, ext = name.match(/^(.+?)(\.[^.]+)?$/).to_a
			[ name, (ext || "")]
		else
			name
		end
	end
	 
	# split path
	#
	# @example
	# 	path="/home/a/file"
	# 	split(path)  #=> "/home/a", "file"
	# 	split(path, :all)  #=> "/", "home", "a", "file"
	#
	# @param [String] name
	# @param [Hash] o option
	# @option o [Boolean] :all split all parts
	# @return [Array<String>] 
	def split(name, o={})
		dir, fname = super(name)	
		ret = Array.wrap(basename(fname, o))

		if o[:all]
			loop do
				dir1, fname = File.split(dir)
				break if dir1 == dir
				ret.unshift fname
				dir = dir1
			end
		end
		ret.unshift dir
		ret
	end

	# join paths, skip nil and empty string.
	#
	# @param [*Array<String>] *paths
	# @return [String]
	def join *paths
		# skip nil
		paths.compact!

		# skip empty string
		paths.delete("")

		super(*paths)
	end

	# get parent path
	# 
	# @param [String] path
	# @return [String]
	def parent path
		join(path, "..")
	end

end
