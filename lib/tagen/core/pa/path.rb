class Pa
	module Path

	# alias from File.absolute_path
	# @param [String] path
	# @return [String]
	def absolute(path); File.absolute_path(get(path)) end

	# alias from File.expand_path
	# @param [String] path
	# @return [String]
	def expand(path); File.expand_path(get(path)) end

	# print current work directory
	# @return [String] path
	def pwd() Dir.getwd end

	# change directory
	#
	# @param [String] path
	def cd(path=ENV["HOME"], &blk) Dir.chdir(get(path), &blk) end

	# get path of an object. 
	#
	# return obj#path if object has a 'path' instance method
	#
	# @param [String,Pa] obj
	# @return [String,nil] path
	def get obj
		return obj if String === obj

		begin 
			obj.path
		rescue NoMethodError
			raise Error, "not support type -- #{obj.inspect}(#{obj.class})"
		end
	end

	# extname of a path
	#
	# @example
	# 	"a.ogg" => "ogg"
	# 	"a" => nil
	#
	# @param [String] path
	# @return [String]
	def extname path
		_, ext = get(path).match(/\.([^.]+)$/).to_a
		ext
	end

	# is path an absolute path ?
	#
	# @param [String] path
	# @return [Boolean]
	def absolute?(path) absolute(path) == get(path) end

	# get a basename of a path
	#
	# @param [String] name
	# @param [Hash] o options
	# @option o [Boolean, String] :ext (false) return \[name, ext] if true
	#   
	# @return [String] basename of a path 
	# @return [Array<String,String>] \[name, ext] if o[:ext] is true
	def basename(name, o={})
		name = File.basename(get(name))
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
		dir, fname = File.split(get(name))
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
		paths.map!{|v|get(v)}

		# skip nil
		paths.compact!

		# skip empty string
		paths.delete("")

		File.join(*paths)
	end

	# get parent path
	# 
	# @param [String] path
	# @return [String]
	def parent path
		join(get(path), "..")
	end

	# link
	#
	# @overload ln(src, dest)
	# @overload ln([src,..], directory)
	#
	# @param [Array<String>, String] src_s support globbing
	# @param [String] dest
	# @param [Hash] o option
	# @option o [Boolean] :force overwrite if exists.
	# @return [nil]
	def ln(src_s, dest, o={}) _ln(File.method(:link), src_s, dest, o) end

	# ln force
	#
	# @see ln
	# @return [nil]
	def ln_f(src_s, dest, o) o[:force]=true; _ln(File.method(:link), src_s, dest, o) end

	# symbol link
	#
	# @see ln
	# @return [nil]
	def symln(src_s, dest, o) _ln(File.method(:symlink), src_s, dest, o) end
	alias symlink ln

	# symln force
	#
	# @see ln
	# @return [nil]
	def symln_f(src_s, dest, o) o[:force]=true; _ln(File.method(:symlink), src_s, dest, o) end

	# param
	def _ln(method, src_s, dest, o={})
		dest = Pa(dest)
		glob(*Array.wrap(src_s)) {|src|
			dest = dest.join(src.b) if dest.directory?
			rm_r(dest) if o[:force] and dest.exists?
			method.call(src.p, dest.p)
		}	
	end
	private :_ln

	# @see File.readlink
	def readlink(path) File.readlink(get(path)) end


	# is path a dangling symlink?
	#
	# a dangling symlink is a dead symlink.
	#
	# @param [String] path
	# @return [Boolean]
	def dangling? path
		path=get(path)
		if symlink?(path)
			src = readlink(path)
			not exists?(src)
		else
			nil
		end
	end # def dsymlink?

end
end
