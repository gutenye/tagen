=begin
# Pa(Path) is similary to Pathname, but more powerful,
# it conbimes fileutils, tmpdir, find, tempfile, File, Dir, Pathname
#
# @example 
#   pa = Pa('/home/a.vim')
#   pa.path  	#=> '/home'
#   pa.fname 	#=> 'a.vim'
#   pa.name 	#=> 'a'
#   pa.ext  	#=> 'vim'
#   pa.fext		#=> '.vim'


/home/guten.ogg
	base: guten.ogg
	dir: /home
	ext: ogg
	file: guten

similar in a shell, basename dirname extname filename absolutename


**Attributes**

	name		abbr		description

	path			p			
	absolute	a			absolute path
	dir				d			dirname of a path
	base			b			basename of a path
	file			f			filename of a path
	ext				e			extname of a path,	return nil or "ogg"	
	fext			fe		return nil or ".ogg"
	relative	r			relative path, passed by Pa(path, relative)

=end

class Pa < File 
	Error = Class.new Exception

	attr_reader :path, :absolute, :dir, :base, :file, :ext, :fext, :relative
	def initialize path, relative=nil
		@path = path
		@absolute = Pa.absolute(@path) 
		@dir = Pa.dirname(@path)
		@base = Pa.basename(@path) 
		@file = Pa.basename(@path, true)[0] 
		@ext = Pa.extname(@path) 
		@fext = @ext.nil? ? nil : "."+@ext
		@relative = relative
	end

	alias p path
	alias a absolute
	alias d dir
	alias	b base
	alias f file
	alias e ext
	alias fe fext
	alias r relative

	def inspect
		ret="#<" + self.class.to_s + " "
		ret += "@path=\"#{@path}\", @absolute=\"#{@absolute}\", @relative=\"#{@relative}"
		ret += " >"
		ret
	end
	alias to_s inspect

	def method_missing(name, *args)
		self.class.__send__ name, @path, *args
	end
end

class Pa     # ¤path
class<<self
	undef_method :open, :truncate

	# "a.ogg" => "ogg"
	# "a" => nil
	def extname path
		_, ext = path.match(/\.([^.]+)$/).to_a
		ext
	end

	alias absolute absolute_path
	alias expand expand_path

	def absolute?(path) absolute(path) == path end

	# o@ :ext or ext:".ogg"
	def basename(name, *o)
		o = o.to_o
		name = super(name)
		if o[:ext]
			_, name, ext = name.match(/^(.+?)(\.[^.]+)?$/).to_a
			[ name, ext]
		else
			name
		end
	end
	 
	# "/home/a/file"
	# 	split  			=> "/home/a", "file"
	# 	split(:all) => "/", "home", "a", "file"
	def split(name, *o)
		o = o.to_o
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

	# skip nil and error at empty string.
	def join *paths
		raise Error, "path is empty string -- #{paths}" if paths.include? ""
		paths.compact!
		super(*paths)
	end

	def parent path
		join(path, "..")
	end

	# o@ :dot
	# return@ []
	#
	# glob is * ** ? [set] {a,b}
	def glob(path, *o)
		o = o.to_o
		flag = 0
		if o[:dot]
			flag |= File::FNM_DOTMATCH
		end

		files = Dir.glob(path, flag)
		files.delete(".", "..")
		files
	end

	# return@ [[]]
	def glob_s(path_s, *o)
		paths = path_s.to_array

		ret = paths.collect do |path|
			glob(path, *o)
		end
		ret
	end
end # class << self
end # class Pa

class << Pa     # ¤state
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
	# is path a dangling symlink ?
	def dangling? path
		if symlink?(path)
			src = readlink(path)
			not exists?(src)
		else
			nil
		end
	end # def dsymlink?
	def mountpoint?
		begin
			stat1 = self.lstat
			stat2 = self.parent.lstat
			stat1.dev == stat2.dev && stat1.ino == stat2.ino || stat1.dev != stat2.dev
		rescue ENotEnt
			false
		end
	end

	def chmod(path_s, mode) super(mode, *path_s.to_array) end
	def lchmod(path_s, mode) super(mode, *path_s.to_array) end
	def chown(path_s, owner, group) super(owner, group, *path_s.to_array) end
	def lchown(path_s, owner, group) super(owner, group, *path_s.to_array) end
	def utime(path_s, atime, mtime) 
		path_s.to_array.each do |path|
			atime ||= lstat(path).atime
			mtime ||= lstat(path).mtime
			super(atime, mtime, path)
		end
	end
end

class << Pa     # ¤dir
	def empty?(path) Dir.entries(path).empty? end

	# ls(path=".", start=1 or memo)
	#
	# options
	#   :rescurive 
	#   :_all(:_dot, :_bak)
	#
	#   'level'=nil start with 1
	def ls(*args, &blk)
		o = args.to_o :dot, :bak, :all
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
	def ls_r(*args, &blk)
		o = args.to_o
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

end

class << Pa     # ¤cmd

	##### pwd cd chroot
	def pwd() Dir.getwd end
	def cd(path=ENV["HOME"], &blk) Dir.chdir(path, &blk) end
	def chroot(path) Dir.chroot(path) end

	##### touch mkdir mknod mktmpdir mktmpfile
	def touch(path_s, *o) 		_touch(path_s, *o) end
	def touch_f(path_s, *o) 	_touch(path_s, :force, *o)  end
	# :mode :force :mkdir
	def _touch(path_s, *o)
		o = o.to_o
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

	 # mkdir
	def mkdir(path_s, *o) 	_mkdir(path_s, *o) end
	def mkdir_f(path_s, *o) _mkdir(path_s, :force, *o) end
	def _mkdir(path_s, *o)
		o = o.to_o
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


	# (paths, type, o={})
	# type@ :chardev :blockdev :fifo
	# o@  
	# 	mode:0644
	# 	dev: /home is lstat("/home").rdev. default is 0
	# def _mknod(path, type, mode, dev)
	#    type@ ?c ?b ?f ?p
	#    BUG 0777 -> 0755
	def mknod(path_s, type, *o) 	_mknod(path_s, type, *o) end
	def mknod_f(path_s, type, *o) _mknod(path_s, type, :force, *o) end

	def _mknod(path_s, type, *o)
		paths = path_s.to_array
		o = args.to_o
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

	def mktmpdir(o={}, &blk) 
		p = _mktmpname(o)
		mkdir(p)
		begin blk.call(p) ensure rm_r(p) end if blk
		p
	end # def mktmpdir
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

	#### rm
	# :force  no Errno::ENOENT
	def delete(path, *o)
		o = o.to_o
		return if o[:force] and !exists?(path)
		File.delete(path)
	end

	def rm(path_s) 		_rm(path_s) end
	def rm_r(path_s) 	_rm(path_s, :rescurive) end
	def rm_f(path_s) 	_rm(path_s, :force) end
	def rm_rf(path_s) _rm(path_s, :rescurive, :force) end
	def _rm(path_s, *o)
		o = o.to_o
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

	# I'm rescurive 
	def _rmdir(path, o)
		ls(path) do|pa|
			pa.directory? ? _rmdir(pa.p, o) : delete(pa.p, o)
		end
		directory?(path) ? Dir.rmdir(path) : delete(path, o)
	end

	#### cp and mv

	def cp(src_s, dest_pa, *o)
		method = self.method(:_copy)
		_cpmv(method, src_s, dest_pa, *o)
	end

	# use rename for same device. and cp for cross device.
	def mv(src_s, dest_pa, *o)
		method = self.method(:_move)
		_cpmv(method, src_s, dest_pa, *o)
	end

	# for cp() and mv()
	# use method.call  # _copy and _move
	def _cpmv(method, src_s, dest_pa, *o)
		o = o.to_o
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
	def rename(old, dest, o=nil); mv(old, dirname(old)+"/#{dest}", o) end

	# path@ dir fpath
	# o@ :force
	def ln(src_s, path, *o) _ln(method(:symlink), src_s, path, *o) end
	def ln_f(src_s, path, *o) _ln(method(:symlink), src_s, path, :force, *o) end
	def symln(src_s, path, *o) _ln(method(:link), src_s, path, *o) end
	def symln_f(src_s, path, *o) _ln(method(:link), src_s, path, :force, *o) end

	def _ln(method, src_s, path, *o)
		o = o.to_o
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
end

module Kernel
	def Pa(path, relative=nil)
		Pa.new path, relative
	end
	private :Pa
end

