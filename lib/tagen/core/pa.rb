=begin
Pa(Path) is similary to Pathname, but more powerful.
it combines fileutils, tmpdir, find, tempfile, File, Dir, Pathname

Examples:
---------
	pa = Pa('/home/a.vim')
	pa.path  	#=> '/home'
	pa.fname 	#=> 'a.vim'
	pa.name 	#=> 'a'
	pa.ext  	#=> 'vim'
	pa.fext		#=> '.vim'


Filename parts:
---------
	/home/guten.ogg
	  base: guten.ogg
	  dir: /home
	  ext: ogg
	  file: guten

similar in a shell, basename dirname extname filename absolutename

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
  file      f      filename of a path
  ext       e      extname of a path,  return nil or "ogg"  
  fext      fe     return nil or ".ogg"
  relative  r      relative path, passed by Pa(path, relative)
=end
class Pa < File 
	Error = Class.new Exception

	class<<self
		undef_method :open, :truncate

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

		alias absolute absolute_path
		alias expand expand_path

		# is path an absolute path ?
		#
		# @param [String] path
		# @return [Boolean]
		def absolute?(path) absolute(path) == path end

		# get a basename of a path
		#
		# @param [String] name
		# @param [] *o Guten style options, see extract_extra_options!
		# options:
		#   :ext (Boolean, String) wether keep extname.
		#   
		# @return [String] 
		def basename(name, *o)
			o = o.extract_extend_options!
			name = super(name)
			if o[:ext]
				_, name, ext = name.match(/^(.+?)(\.[^.]+)?$/).to_a
				[ name, ext]
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
		# @param [] *o Guten style options, see extract_extra_options!
		# @return [Array<String>]
		def split(name, *o)
			o = o.extract_extend_options!
			dir, fname = super(name)	
			ret = basename(fname, o).to_array

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

		# join paths, skip nil and error at empty string.
		#
		# @param [*Array<String>] *paths
		# @return [String]
		def join *paths
			raise Error, "path is empty string -- #{paths}" if paths.include? ""
			paths.compact!
			super(*paths)
		end

		# get parent path
		# 
		# @param [String] path
		# @return [String]
		def parent path
			join(path, "..")
		end

		# glob is * ** ? [set] {a,b}
		#
		# @param [String] path
		# @param [] *o Guten style options, see extract_extra_options!
		# @return [Array<String>] 
		def glob(path, *o)
			o = o.extract_extend_options!
			flag = 0
			if o[:dot]
				flag |= File::FNM_DOTMATCH
			end

			files = Dir.glob(path, flag)
			files.delete(".", "..")
			files
		end

		# glob_s
		#
		# @param [Array,String] path_s
		# @param [] *o Guten style options, see extract_extra_options!
		#
		# @return [[]]
		def glob_s(path_s, *o)
			paths = path_s.to_array

			ret = paths.collect do |path|
				glob(path, *o)
			end
			ret
		end
	end # class << self


	attr_reader :path, :absolute, :dir, :base, :file, :ext, :fext, :relative
	alias p path
	alias a absolute
	alias d dir
	alias	b base
	alias f file
	alias e ext
	alias fe fext
	alias r relative

	# @param [String,Pathname,Pa] path
	# @prams [String] relative relative path, used by {#ls_r}
	def initialize path, relative=nil
		@path = case path.class.to_s
			when "Pathname"
				path.to_s
			when "Pa"
				path.path
			when "String"
				path
			end
		@absolute = Pa.absolute(@path) 
		@dir = Pa.dirname(@path)
		@base = Pa.basename(@path) 
		@file = Pa.basename(@path, ext: true)[0] 
		@ext = Pa.extname(@path) 
		@fext = @ext.nil? ? nil : "."+@ext
		@relative = relative
	end

	# @return [String]
	def inspect
		ret="#<" + self.class.to_s + " "
		ret += "@path=\"#{@path}\", @absolute=\"#{@absolute}\", @relative=\"#{@relative}"
		ret += " >"
		ret
	end
	alias to_s inspect

	# missing methods goto Pa.method (Pa's class method)
	def method_missing(name, *args)
		self.class.__send__ name, @path, *args
	end


	
	## state 
	#

	# get file type
	#
	# file types:
	#   "chardev" "blockdev" "symlink" ..
	#
	# @param [String] path
	# @return [String] 
	def type(path)
		case (t=ftype(path))
		when "characterSpecial"
			"chardev"
		when "blockSpecial"
			"blockdev"
		when "link"
			"symlink"
		else
			t
		end
	end # def type

	# is path a dangling symlink?
	#
	# a dangling symlink is a dead symlink.
	#
	# @param [String] path
	# @return [Boolean]
	def dangling? path
		if symlink?(path)
			src = readlink(path)
			not exists?(src)
		else
			nil
		end
	end # def dsymlink?

	# is path a mountpoint?
	#
	# @param[String] path
	# @return [Boolean]
	def mountpoint? path
		begin
			stat1 = path.lstat
			stat2 = path.parent.lstat
			stat1.dev == stat2.dev && stat1.ino == stat2.ino || stat1.dev != stat2.dev
		rescue ENotEnt
			false
		end
	end

	# chmod
	#
	# @see {File.chmod}
	# @param [Array<String>, String] path_s
	# @return [nil]
	def chmod(path_s, mode) super(mode, *path_s.to_array) end

	# link chmod
	#
	# @see {File.lchmod}
	# @param [Array<String>, String] path_s
	# @return [nil]
	def lchmod(path_s, mode) super(mode, *path_s.to_array) end

	# chown
	#
	# @see {File.chown}
	# @param [Array<String>, String] path_s
	# @return [nil]
	def chown(path_s, owner, group) super(owner, group, *path_s.to_array) end

	# link chown
	#
	# @see {File.lchown}
	# @param [Array<String>, String] path_s
	# @return [nil]
	def lchown(path_s, owner, group) super(owner, group, *path_s.to_array) end

	# utime
	#
	# @see {File.utime}
	# @param [Array<String>, String] path_s
	# @param [Time] atime
	# @param [Time] mtime
	# @return [nil]
	def utime path_s, atime, mtime
		path_s.to_array.each do |path|
			atime ||= lstat(path).atime
			mtime ||= lstat(path).mtime
			super(atime, mtime, path)
		end
	end

	
	## dir
	#

	# is directory empty?
	#
	# @param [String] path
	# @return [Boolean]
	def empty?(path) Dir.entries(path).empty? end

	# ls(path=".", start=1 or memo)
	#
	# options
	#   :rescurive 
	#   :_all(:_dot, :_bak)
	#
	#   'level'=nil start with 1
	def ls(*args, &blk)
		o = args.extract_extend_options! :dot, :bak, :all
		if not o[:all] then o[:dot]=false; o[:bak]=false end
		o[:level] = o[:rescurive] ? nil : 1
		o[:start] = 0
		o[:memo] = nil # memo
		pa = Pa(".")
		args.each {|arg|
			case arg
			when Fixnum
				o[:start] = arg
			when String
				pa = Pa(arg)
			else
				o[:memo] = arg
			end
		}
		return if not pa.directory?

		blk = proc { |pa| pa.r } if not blk

		opt={ :ret => [], :level => 0 }
		_ls(pa, o, opt, &blk)
	end

	# ls rescurive
	def ls_r(*args, &blk)
		o = args.extract_extend_options!
		o[:rescurive] = true
		ls(*args, o, &blk)
	end

	# I'm rescurive
	# use :level, not :rescurive
	# opt@ .ret=[] level=0
	def _ls(pa, o, opt, &blk)
		opt[:level] += 1
		return if o[:level]!=nil and opt[:level] > o[:level]

		err = nil
		begin
			dir = Dir.open(pa.path)
		rescue EPerm, ENoEnt => e
			err = e
		end

		dir.each do |fname|
			next if %w(. ..).include? fname
			next if (not o[:dot]) and fname=~/^\./
			next if (not o[:bak]) and fname=~/~$/

			pa1 = Pa(join(pa.p, fname), join(pa.r, fname))
			blk_rst = blk.call(pa1, o[:start], o[:memo], err) 
			opt[:ret] << blk_rst if o[:nil] or !blk_rst.nil?

			o[:start] += 1
			_ls(pa1, o, opt, &blk) if pa1.directory? and not pa1.symlink?
		end

		o[:memo] ? o[:memo] : opt[:ret]
	end
	private :_ls

	## cmd
	#

	# print current work directory
	# @return [String] path
	def pwd() Dir.getwd end

	# change directory
	#
	# @param [String] path
	def cd(path=ENV["HOME"], &blk) Dir.chdir(path, &blk) end

	# chroot
	# @see {Dir.chroot}
	#
	# @param [String] path
	# @return [nil]
	def chroot(path) Dir.chroot(path) end

	# touch a blank file
	#
	# @param [Array<String>, String] path_s
	# @param [] *o Guten style options
	# options:
	#   :mode
	#   :force
	#   :mkdir
	#
	# @return [nil]
	def touch(path_s, *o) 		_touch(path_s, *o) end

	# touch force
	# see {#touch}
	#
	# @param [Array<String>, String] path_s
	# @pram [] *o Guten style options
	# @return [nil]
	def touch_f(path_s, *o) 	_touch(path_s, :force, *o)  end

	# :mode :force :mkdir
	def _touch(path_s, *o)
		o = o.extract_extend_options!
		o[:mode] ||= 0644
		paths = path_s.to_array
		paths.each {|p|
			if exists?(p) 
				o[:force] ? next : raise(Errno::EEXIST, "File exist -- #{p}")
			end

			if o[:mkdir]
				mkdir(dirname(p))
			end

			if win32?
				# win32 BUG. must f.write("") then file can be deleted.
				File.open(p, "w"){|f| f.chmod(o[:mode]); f.write("")} 
			else
				File.open(p, "w"){|f| f.chmod(o[:mode])}
			end
		}
	end
	private :_touch

	# make a directory
	# @param [Array<String>,String] path_s
	# @param [] *o opts
	# @return [nil]
	def mkdir(path_s, *o) 	_mkdir(path_s, *o) end

	# mkdir force
	#
	# @see mkdir
	# @return [nil]
	def mkdir_f(path_s, *o) _mkdir(path_s, :force, *o) end

	def _mkdir(path_s, *o)
		o = o.extract_extend_options!
		o[:mode] ||= 0744
		paths = path_s.to_array
		paths.each {|p|
			if exists?(p)
				o[:force] ? next : raise(Errno::EEXIST, "File exist -- #{p}")
			end

			stack = []
			until p == stack.last
				break if exists?(p)
				stack << p
				p = dirname(p)
			end

			stack.reverse.each do |path|
				Dir.mkdir(path)
				chmod(path, o[:mode])
			end
		}
	end
	private :_mkdir


	# mknode
	# @note not implement yet
	#
	# (paths, type, o={})
	# type@ :chardev :blockdev :fifo
	# o@  
	# 	mode:0644
	# 	dev: /home is lstat("/home").rdev. default is 0
	# def _mknod(path, type, mode, dev)
	#    type@ ?c ?b ?f ?p
	#    BUG 0777 -> 0755
	def mknod(path_s, type, *o) 	_mknod(path_s, type, *o) end

	# mknode force
	#
	# @see mknod
	# @return [nil]
	def mknod_f(path_s, type, *o) _mknod(path_s, type, :force, *o) end

	def _mknod(path_s, type, *o)
		paths = path_s.to_array
		o = args.extract_extend_options!
		o[:mode] ||= 0644
		type = case type
			when :file; 'f'   # same as normal file
			when :chardev; 'c' 
			when :blockdev; 'b'
			when :fifo; 'p'
			end
			
		paths.each {|p|
			if exists?(p)
				o[:force] ? next : raise(Errno::EEXIST, "File exist -- #{p}")
			end

			dev = o[:dev] ? lstat(o[:dev]).rdev : 0
			__mknod(p, type, o[:mode], dev)
			chmod(p, o[:mode])
		}
	end # def mknod
	private :_mknod

	# make temp directory
	#
	# @param [Hash] o options
	# @option o [Symbol] :prefix ("")
	# @option o [Symbol] :suffix ("")
	# @option o [Symbol] :tmpdir (ENV["TEMP"])
	# @return [String] path
	def mktmpdir(o={}, &blk) 
		p = _mktmpname(o)
		mkdir(p)
		begin blk.call(p) ensure rm_r(p) end if blk
		p
	end # def mktmpdir

	# make temp file
	# @see mktmpdir
	#
	# @param [Hash] o options
	# @return [String] path
	def mktmpfile(o={}, &blk) 
		p = _mktmpname(o) 
		begin blk.call(p) ensure rm(p) end if blk
		p
	end # mktmpfile

	def _mktmpname(o={})
		# :prefix :suffix :tmpdir
		# $$-(time*100_000).to_i.to_s(36)
		# parse o
		o[:dir] ||= ENV["TEMP"]
		o[:prefix] ||= ""
		o[:suffix] ||= ""

		# begin
		collision = 0
		path = "#{o[:dir]}/#{o[:prefix]}#{$$}-#{(Time.time*100_000).to_i.to_s(36)}"
		orgi_path = path.dup
		while exists?(path)
		path = orgi_path+ collision.to_s
		collision +=1
		end
		path << o[:suffix]

		path
	end # def mktmpname
	private :_mktmpname

	# delete a file
	#
	# @param [String] path
	# @param [] *o options
	# options:
	#   :force
	# @return [nil]
	def delete(path, *o)
		o = o.extract_extend_options!
		return if o[:force] and !exists?(path)
		File.delete(path)
	end

	# rm file only
	#
	# @param [Array<String>, String] path_s support globbing
	# @return [nil]
	def rm(path_s) 		_rm(path_s) end

	# rm rescurive, rm directory
	#
	# @see rm
	# @return [nil]
	def rm_r(path_s) 	_rm(path_s, :rescurive) end

	# rm force
	#
	# @see rm
	# @return [nil]
	def rm_f(path_s) 	_rm(path_s, :force) end

	# rm rescurive and force 
	#
	# @see rm
	# @return [nil]
	def rm_rf(path_s) _rm(path_s, :rescurive, :force) end

	def _rm(path_s, *o)
		o = o.extract_extend_options!
		pathss = glob_s(path_s)
		pathss.each do |paths|
			paths.each { |path|
				if !exists?(path)
					o[:force] ? next : raise(Errno::ENOTENT, "path doesn't exists -- #{path}")
				end

				if directory?(path) 
					_rmdir(path, o) if o[:rescurive]
				else
					delete(path, o)
				end
			}
		end
	end
	private :_rm

	# I'm rescurive 
	def _rmdir(path, o)
		ls(path) do|pa|
			pa.directory? ? _rmdir(pa.p, o) : delete(pa.p, o)
		end
		directory?(path) ? Dir.rmdir(path) : delete(path, o)
	end
	private :_rmdir

	# copy
	#
	# @param [Array<String>,String] src_s support globbing
	# @param [String] dest_pa
	# @param [] *o guten's options
	# options:
	#  :verbose
	#  :follink follow link
	#  :backupdest backup dest file when dest exists
	#  :update only copy when src are newer then dest, ctime
	#  :diff only copy when at different mtime
	#  :fromfs only copy if same file system
	#  :rmdestdir rm dest dir if dest is a directory
	#  :overwrite overwrite dest file if dest is a file
	#  :path support auto mkdir. Example: cp a/b dest #=> dest/a/b
	#  :mkdir cp a dest/b/c if 'dest/b/c' not exists auto mkdir
	# @return [nil]
	def cp(src_s, dest_pa, *o)
		method = self.method(:_copy)
		_cpmv(method, src_s, dest_pa, *o)
	end

	# move, use rename for same device. and cp for cross device.
	# @see cp
	#
	# @param [Array<String, String] src_s support globbing
	# @param [String] dest_pa
	# @param [] *o guten's optioins
	# @return [nil]
	def mv(src_s, dest_pa, *o)
		method = self.method(:_move)
		_cpmv(method, src_s, dest_pa, *o)
	end

	# for cp() and mv()
	# use method.call  # _copy and _move
	def _cpmv(method, src_s, dest_pa, *o)
		o = o.extract_extend_options!
		srcss = glob_s(src_s)

		# 'mkdir'
		mkdir_f(dirname(dest_pa)) if o[:mkdir]

		# 'rmdestdir'
		rm_r dest_pa if o[:rmdestdir] and directory?(dest_pa)

		# dest_pa must be directory for
		#   o[:parent] 
		#   src_s is array
		if (Array===src_s or o[:parent]) and (not directory?(dest_pa)) 
			raise Errno::ENOTDIR, "target is not a directory -- #{dest_pa}"
		end

		# o[:parent] only implement in linux 
		if o[:parent] and win32?
			raise Pa::Error, "option `parent' is for linux operation system only."
		end

		srcss.each {|srcs|
			srcs.each {|src|
				dest = 
					if directory?(dest_pa)
						# 'parent' 'path'
						dest1 = if o[:parent] then absolute(src) elsif o[:path] then src else basename(src) end
						dest1 = join(dest_pa, dest1)
						mkdir_f dirname(dest1)
						dest1
					else
						dest_pa
					end

				# cp name dir/
				#  is to dir/name
				
				# cp name/ dir/   in _copy
				#  is to dir/name/

				# cp name dir/name/
				#  is EEXIST
				raise EEXIST, "can't copy name to dir/name/. -- #{src} |--| #{dest}" if 
						directory?(dest) and !directory?(src)

				# cp name/ dir/name/    in _copy
						
				method.call src, dest, o
			}
		}
	end # def mv
	private :_cpmv

	# I'm recursive 
	def _copy(src, dest, o={})  
		#p "_copy", src, dest
		o[:formfs] = o[:fromfs].to_array

		o[:formfs].each {|fs| return if lstat(fs).dev != lstat(src).dev }

		# begin
		if exists?(dest) and !directory?(src)
			# :update
			if o[:update]
				return if mtime(src) <= mtime(dest)
			# :diff
			elsif o[:diff]
				return if mtime(src) == mtime(dest)
			elsif o[:backupdest] 
				_copy dest, dest+"~"
				rm dest
			elsif o[:overwrite]
				rm dest
			else
				raise Errno::EEXIST, "Path exists -- #{dest}" if exists?(dest)
			end
		end

		case type=self.type(src)
		when "file", "socket"
			echo "cp #{src} #{dest}" if o[:verbose]
			copy_stream(src, dest)
		when "directory"
			begin
				mkdir dest
				echo "mkdir #{dest}" if o[:verbose]
			rescue Errno::EEXIST
			end
			ls(src) { |pa|
				_copy(pa.p, join(dest, pa.fn), o)
			}
		when "symlink"
			if o[:follink] 
				_copy(readlink(src), dest) 
			else
			 symlink(readlink(src), dest)	
				echo "symlink #{src} #{dest}" if o[:verbose]
			end
		when "chardev", "blockdev", "fifo"
			mknod(dest, type, dev=src)
			echo "mknod #{dest}(:#{type})" if o[:verbose]
		when "unknow"
			raise Error, "Can't handle unknow type(#{:type}) -- #{src}"
		end

		# chmod chown utime
		src_stat = o[:follink] ? stat(src) : lstat(src)
		begin
			chmod(dest, src_stat.mode)
			chown(dest, src_stat.uid, src_stat.gid)
			utime(dest, src_stat.atime, src_stat.mtime)
		rescue Errno::ENOENT
		end
	end # _copy
	private :_copy

	# I'm rescurive
	def _move(src, dest, o=nil)

		# mv "name/ dirb/name/" overwrite=true
		if directory?(src) and directory?(dest)
			if o[:overwrite]
				ls(src) { |pa|
					newdest = join(parent(dest), pa.p)
					rm newdest
					_move pa.p, newdest, o
				}
				rm_r(src)
			else
				raise Errno::EEXIST, "mv name/ dirb/name/ -- #{src} |==| #{dest}"
			end

		# mv "name/ dirb/" 
		# mv "name dirb/"
		else
			begin
				File.rename(src, dest)
			rescue Errno::EXDEV # cross-device
				_copy(src, dest)
				rm_r(src)
			end

		end
	end # def _move
	private :_move

	# rename 
	# 
	# @param [String] old
	# @param [String] dest
	# @param [Hash] o
	# @return nil
	def rename(old, dest, o=nil); mv(old, dirname(old)+"/#{dest}", o) end

	# path@ dir fpath
	# o@ :force
	# link
	#
	# @param [Array<String>, String] src_s support globbing
	# @param [String] path
	# @param [] *o
	# options: 
	#   :force [Boolean] 
	# @return [nil]
	def ln(src_s, path, *o) _ln(method(:symlink), src_s, path, *o) end

	# ln force
	#
	# @see ln
	# @return [nil]
	def ln_f(src_s, path, *o) _ln(method(:symlink), src_s, path, :force, *o) end

	# symbol link
	#
	# @see ln
	# @return [nil]
	def symln(src_s, path, *o) _ln(method(:link), src_s, path, *o) end

	# symln force
	#
	# @see ln
	# @return [nil]
	def symln_f(src_s, path, *o) _ln(method(:link), src_s, path, :force, *o) end

	def _ln(method, src_s, path, *o)
		o = o.extract_extend_options!
		srcss = glob_s(src_s)
		srcss.each do |srcs|
			srcs.each {|src|
				dest = join(path, basename(src)) if directory?(path)
				rm_r(dest, :force) if o[:force]
				method.call(src, dest)
				o[:symln] ? symlink(src, dest) : link(src, dest)
			}	
		end
	end
	private :_ln

end

module Kernel
private
	# a very convient function.
	# 
	# @example
	#   Pa('/home').exists? 
	def Pa(path, relative=nil)
		Pa.new path, relative
	end
end

