=begin
Pa(Path) is similary to Pathname, but more powerful.
it combines fileutils, tmpdir, find, tempfile, File, Dir, Pathname

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

class Pa < File
	undef :open

	Error = Class.new Exception

	attr_accessor :path
	attr_reader :absolute, :dir, :base, :name, :ext, :fext
	alias p path
	alias a absolute
	alias d dir
	alias	b base
	alias n name
	alias e ext
	alias fe fext

	# @param [String,Pathname,Pa] path
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

	# @return [String]
	def inspect
		ret="#<" + self.class.to_s + " "
		ret += "@path=\"#{@path}\", @absolute=\"#{@absolute}\""
		ret += " >"
		ret
	end
	alias to_s inspect

	# join path
	#
	# param [String] *names
	# return [Pa]
	def join(*names)
		Pa(Pa.join(@path, *names))
	end

	# get parent path
	# 
	# return [Pa] 
	def parent
		Pa(Pa.join(@path, '..'))
	end

	# missing method goes to Pa.class-method 
	def method_missing(name, *args)
		self.class.__send__ name, *args, @path
	end
end

require_relative "pa/path"
require_relative "pa/cmd"
require_relative "pa/dir"
require_relative "pa/state"
class <<Pa
	alias absolute absolute_path
	alias expand expand_path
end
class Pa
	extend Path
	extend Dir
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

