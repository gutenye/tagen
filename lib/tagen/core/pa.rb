=begin rdoc
Pa(Path) is similary to Pathname, but more powerful.
it combines fileutils, tmpdir, find, tempfile, File, Dir, Pathname

all class methods support Pa as parameter.

Examples:
---------
	pa = Pa('/home/a.vim')
	pa.dir  	#=> '/home'
	pa.base 	#=> 'a.vim'
	pa.name 	#=> 'a'
	pa.ext  	#=> 'vim'
	pa.fext		#=> '.vim'

Filename parts:
---------
	/home/guten.ogg
	  base: guten.ogg
	  dir: /home
	  ext: ogg
	  name: guten

Additional method list
---------------------
* Pa.absolute _alias from `File.absolute_path`_
* Pa.expand _aliss from `File.expand_path`_

=== create, modify path
Example1:
	pa = Pa('/home/foo')
	pa.join('a.txt') #=> new Pa('/home/foo/a.txt')

Example2:
	pa1 = Pa('/home/foo/a.txt')
	pa2 = Pa('/home/bar/b.txt')
	pa1+'~' #=> new Pa('/home/foo/a.txt~')
	Pa.join(pa1.dir, pa2.base) #=> '/home/foo/b.txt'

Example3:
	pa1 = Pa('/home/foo/a.txt')
	pa2 = Pa('/home/bar')
	pa2.join(pa1.base)  #=> new Pa('/home/bar/a.txt')
		
**Attributes**

  name     abbr    description

  path      p      
  absolute  a      absolute path
  dir       d      dirname of a path
  base      b      basename of a path
  name      n      filename of a path
  ext       e      extname of a path,  return "" or "ogg"  
  fext      fe     return "" or ".ogg"
=end

class Pa 
	Error = Class.new Exception
	EUnkonwType = Class.new Error

	attr_accessor :path
	attr_reader :absolute, :dir, :base, :name, :ext, :fext

	# @param [String,Pa,Pathname] path
	# @api also used by replace
	def initialize path
		@path = case path.class.to_s
			when "Pathname"
				path.to_s
			when "Pa"
				path.path
			when "String"
				path
			else
				raise ArgumentError, path.inspect
			end
		@absolute = Pa.absolute(@path) 
		@dir = Pa.dirname(@path)
		@base = Pa.basename(@path) 
		@name, @ext = Pa.basename(@path, ext: true)
		@fext = @ext.empty? ? "" : "."+@ext
	end

	alias p path
	alias a absolute
	alias d dir
	alias	b base
	alias n name
	alias e ext
	alias fe fext

	def absolute_pa() Pa(absolute) end
	def dir_pa() Pa(dir) end

	# @param [String,Pa,Pathname]
	# @return [Pa] the same Pa object
	def replace path
		initialize path
	end

	# add string to path
	# 
	# @example 
	#  pa = Pa('/home/foo/a.txt')
	#  pa+'~' #=> new Pa('/home/foo/a.txt~')
	#
	# @param [String] str
	# @return [Pa]
	def + str
		Pa(@path+str)
	end

	# return '#<Pa @path="foo", @absolute="/home/foo">'
	#
	# @return [String]
	def inspect
		ret="#<" + self.class.to_s + " "
		ret += "@path=\"#{@path}\", @absolute=\"#{@absolute}\""
		ret += " >"
		ret
	end

	# return '/home/foo'
	#
	# @return [String] path
	def to_s
		@path
	end

	# join path
	#
	# param [String] *names
	# return [Pa]
	def join(*names)
		Pa(Pa.join(@path, *names))
	end

	# missing method goes to Pa.class-method 
	# return@ [Pa,..] return Pa for some methods.
	def method_missing(name, *args, &blk)
		ret = self.class.__send__(name, *args, @path, &blk)
		[ :readlink, :parent ]
			.include?(name) ? Pa(ret) : ret
	end
end


require_relative "pa/path"
require_relative "pa/cmd"
require_relative "pa/dir"
require_relative "pa/state"
class Pa
class << self

	# missing method goes to File class method
	def method_missing name, *args, &blk
		return if args.size>1
		File.__send__ name, get(args[0]), &blk
	end

end
end

class Pa
	extend Path
	extend Directory
	extend State
	extend Cmd
end

module Kernel
private
	# a very convient function.
	# 
	# @example
	#   Pa('/home').exists? 
	def Pa(path)
		return path if Pa===path
		Pa.new path
	end
end

