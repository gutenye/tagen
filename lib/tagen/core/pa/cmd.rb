module Pa::Cmd
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
	# @param [Hash] o option
	# @option o [Fixnum,String] :mode
	# @option o [Boolean] :mkdir
	# @return [nil]
	def touch(path_s, o) 		_touch(path_s, o) end

	# touch force
	# see touch
	#
	# @return [nil]
	def touch_f(path_s, o={}) o[:force]=true; 	_touch(path_s, o)  end

	def _touch(path_s, o={})
		o[:mode] ||= 0644
		paths = Array.wrap(path_s)
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
	#
	# @param [Array<String>,String] path_s
	# @param [Hash] o option
	# @option o [Fixnum] :mode
	# @return [nil]
	def mkdir(path_s, o) 	_mkdir(path_s, o) end

	# mkdir force
	#
	# @see mkdir
	# @return [nil]
	def mkdir_f(path_s, o) o[:force]=true; _mkdir(path_s, o) end

	def _mkdir(path_s, o)
		o[:mode] ||= 0744
		paths = Array.wrap(path_s)
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
	# @param [Hash] o options
	# @option o [Boolean] :force (false)
	# @return [nil]
	def delete(path, o={})
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
	def rm_r(path_s) 	_rm(path_s, rescurive: true) end

	# rm force
	#
	# @see rm
	# @return [nil]
	def rm_f(path_s) 	_rm(path_s, force: true) end

	# rm rescurive and force 
	#
	# @see rm
	# @return [nil]
	def rm_rf(path_s) _rm(path_s, rescurive: true, force: true) end

	def _rm(path_s, o={})
		paths = glob(*Array.wrap(path_s))
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
	# @param [Hash] o option
	# @option o [Boolean] :verbose echo cmd when execute
	# @option o [Boolean] :follink follow link
	# @option o [Boolean] :backupdest backup dest file when dest exists
	# @option o [Boolean] :update only copy when src are newer then dest, ctime
	# @option o [Boolean] :diff only copy when at different mtime
	# @option o [String] :fromfs only copy if same file system
	# @option o [Boolean] :rmdestdir rm dest dir if dest is a directory
	# @option o [Boolean] :overwrite overwrite dest file if dest is a file
	# @option o [Boolean] :path support auto mkdir. Example: cp a/b dest #=> dest/a/b
	# @option o [Boolean] :mkdir cp a dest/b/c if 'dest/b/c' not exists auto mkdir
	# @return [nil]
	def cp(src_s, dest_pa, o)
		method = self.method(:_copy)
		_cpmv(method, src_s, dest_pa, o)
	end

	# move, use rename for same device. and cp for cross device.
	# @see cp
	#
	# @return [nil]
	def mv(src_s, dest_pa, o)
		method = self.method(:_move)
		_cpmv(method, src_s, dest_pa, o)
	end

	# for cp() and mv()
	# use method.call  # _copy and _move
	def _cpmv(method, src_s, dest_pa, o={})
		srcs = glob(*Array.wrap(src_s))

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
	end # def mv
	private :_cpmv

	# I'm recursive 
	def _copy(src, dest, o={})  
		#p "_copy", src, dest
		o[:formfs] = Array.wrap(o[:fromfs])

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

	# link
	#
	# @param [Array<String>, String] src_s support globbing
	# @param [String] path
	# @param [Hash] o option
	# @option o [Boolean] :force force overwrite it if dest exists.
	# @return [nil]
	def ln(src_s, path, o={}) _ln(method(:symlink), src_s, path, o) end

	# ln force
	#
	# @see ln
	# @return [nil]
	def ln_f(src_s, path, o) o[:force]=true; _ln(method(:symlink), src_s, path, o) end

	# symbol link
	#
	# @see ln
	# @return [nil]
	def symln(src_s, path, o) _ln(method(:link), src_s, path, o) end

	# symln force
	#
	# @see ln
	# @return [nil]
	def symln_f(src_s, path, o) o[:force]=true; _ln(method(:link), src_s, path, o) end

	def _ln(method, src_s, path, o={})
		srcs = glob(*Array.wrap(src_s))
		srcs.each {|src|
			dest = join(path, basename(src)) if directory?(path)
			rm_r(dest, force: true) if o[:force]
			method.call(src, dest)
			o[:symln] ? symlink(src, dest) : link(src, dest)
		}	
	end
	private :_ln
end
