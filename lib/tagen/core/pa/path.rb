class Pa
	NAME_EXT_PAT = /^(.+?)(?:\.([^.]+))?$/
module ClassMethods::Path

	# alias from File.absolute_path
	# @param [String,Pa] path
	# @return [String]
	def absolute(path); File.absolute_path(get(path)) end

	# alias from File.expand_path
	# @param [String,Pa] path
	# @return [String]
	def expand(path); File.expand_path(get(path)) end

	# shorten a path,
	# convert /home/user/file to ~/file
	#
	# @param [String,Pa] path
	# @return [String]
	def shorten(path);
		get(path).sub(%r!^#{Regexp.escape(ENV["HOME"])}!, "~")
	end

	# return current work directory
	# @return [String] path
	def pwd() Dir.getwd end

	# @return [Pa] path
	def pwd2() Pa(Dir.getwd) end

	# change directory
	#
	# @param [String,Pa] path
	def cd(path=ENV["HOME"], &blk) Dir.chdir(get(path), &blk) end

	# get path of an object. 
	#
	# return obj#path if object has a 'path' instance method
	#
	# @param [String,#path] obj
	# @return [String,nil] path
	def get obj
		if obj.respond_to?(:path)
			obj.path
		elsif String === obj 
			obj
		else
			raise Error, "not support type -- #{obj.inspect}(#{obj.class})"
		end
	end

	# extname of a path
	#
	# @example
	# 	"a.ogg" => "ogg"
	# 	"a" => nil
	#
	# @param [String,Pa] path
	# @return [String]
	def extname path
		_, ext = get(path).match(/\.([^.]+)$/).to_a
		ext
	end

	# is path an absolute path ?
	#
	# @param [String,Pa] path
	# @return [Boolean]
	def absolute?(path) path=get(path); File.absolute_path(path) == path end

	# get a basename of a path
	#
	# @example
	#   Pa.basename("foo.bar.c", ext: true)  #=> \["foo.bar", "c"]
	#
	# @param [String,Pa] name
	# @param [Hash] o options
	# @option o [Boolean, String] :ext (false) return \[name, ext] if true
	#   
	# @return [String] basename of a path unless o[:ext]
	# @return [Array<String>] \[name, ext] if o[:ext].  
	def basename(name, o={})
		name = File.basename(get(name))
		if o[:ext]
			name, ext = name.match(NAME_EXT_PAT).captures
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
	# @param [String,Pa] name
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
	# @param [String,Pa] path
	# @param [Fixnum] n up level
	# @return [String]
	def parent path, n=1
		path = get(path)
		n.times do
			path = File.dirname(path)
		end
		path
	end

	# link
	#
	# @overload ln(src, dest)
	# @overload ln([src,..], directory)
	#
	# @param [Array<String>, String] src_s support globbing
	# @param [String,Pa] dest
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

	# @param [Array,String,#path] src_s
	# @param [String,#path] dest
	def _ln(method, src_s, dest, o={})
		dest = get(dest)
		glob(*Array.wrap(src_s)) {|src|
			src = get(src)
			dest = File.join(dest, File.basename(src)) if File.directory?(dest)
			Pa.rm_r(dest) if o[:force] and File.exists?(dest)
			method.call(src, dest)
		}	
	end
	private :_ln

	# @see File.readlink
	def readlink(path) File.readlink(get(path)) end

	# is path a dangling symlink?
	#
	# a dangling symlink is a dead symlink.
	#
	# @param [String,Pa] path
	# @return [Boolean]
	def dangling? path
		path=get(path)
		if File.symlink?(path)
			src = File.readlink(path)
			not File.exists?(src)
		else
			nil
		end
	end # def dsymlink?

	def realpath(path) File.realpath(get(path)) end

end
end

class Pa
=begin

attribute absolute and dir return String, method absolute_path(), dirname() return Pa
	
	Pa("/home/a").dir #=> "/home"
	Pa("/home/a").dirname #=> Pa("/home")

== methods from String
* +
* [g]sub[!] match =~ 
* start_with? end_with?

=end
module Path
	# @return [String] 
	attr_reader :absolute, :dir, :base, :name, :ext, :fext, :short

	def initialize_variables
		super
		@absolute = File.absolute_path(@path) 
		@dir = File.dirname(@path)
		@base = File.basename(@path) 
		@name, @ext = @base.match(NAME_EXT_PAT).captures
		@ext ||= ""
		@fext = @ext.empty? ? "" : "."+@ext
	end

	alias a absolute
	alias d dir
	alias	b base
	alias n name
	alias fname base
	alias fn fname
	alias e ext
	alias fe fext

	def short
		@short ||= Pa.shorten(@path) 
	end

	# @return [Pa] absolute path
	def absolute2() @absolute2 ||= Pa(absolute) end

	# @return [Pa] dirname
	# @example
	#   Pa(__FILE__).dirname.join('.opts')
	def dir2() @dir2 ||= Pa(dir) end

	# add string to path
	# 
	# @example 
	#  pa = Pa('/home/foo/a.txt')
	#  pa+'~' #=> new Pa('/home/foo/a.txt~')
	#
	# @param [String] str
	# @return [Pa]
	def +(str) Pa(path+str) end

	# @return [Pa]
	def sub(*args,&blk) Pa(path.sub(*args,&blk)) end

	# @return [Pa]
	def gsub(*args,&blk) Pa(path.gsub(*args,&blk)) end

	# @return [Pa]
	def sub!(*args,&blk) self.replace path.sub(*args,&blk) end

	# @return [Pa]
	def gsub!(*args,&blk) self.replace path.gsub(*args,&blk) end

	# @return [MatchData]
	def match(*args,&blk) path.match(*args,&blk) end 

	# @return [Boolean]
	def start_with?(*args) path.start_with?(*args) end

	# @return [Boolean]
	def end_with?(*args) path.end_with?(*args) end

	def =~(regexp) path =~ regexp end

	def ==(other) self.path == other.path end
end
end

