=begin
rm family
	* rm     _rm file only_
	* rmdir  _rm directory only_
	* rm_r   _rm recurive, both file and directory_
	* rm_if  _with condition, use rm_r_
=== Example 
  rm path # it's clear: remove a file
  rmdir path #  it's clear: remove a directory
=end
class Pa
module Cmd

	# chroot
	# @see {Dir.chroot}
	#
	# @param [String] path
	# @return [nil]
	def chroot(path) Dir.chroot(get(path)) end

	# touch a blank file
	#
	# @overload touch(*paths, o={})
	#   @param [String] *paths
	#   @param [Hash] o option
	#   @option o [Fixnum,String] :mode
	#   @option o [Boolean] :mkdir auto mkdir if path contained directory not exists.
	#   @option o [Boolean] :force 
	#   @return [nil]
	def touch(*args) paths, o = args.extract_options; _touch(*paths, o) end

	# touch force
	# @see touch
	#
	# @overload touch_f(*paths, o={})
	#   @return [nil]
	def touch_f(*args) paths, o = args.extract_options; o[:force]=true; 	_touch(*paths, o) end

	def _touch(paths, o)
		o[:mode] ||= 0644
		paths.map!{|v|get(v)}
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
	# @overload mkdir(*paths, o={})
	#   @param [String] *paths
	#   @param [Hash] o option
	#   @option o [Fixnum] :mode
	#   @option o [Boolean] :force
	#   @return [nil]
	def mkdir(*args) paths, o = args.extract_options; _mkdir(paths, o) end

	# mkdir force
	# @see mkdir
	#
	# @overload mkdir_f(*paths, o={})
	#   @return [nil]
	def mkdir_f(*args) paths, o = args.extract_options; o[:force]=true; _mkdir(*paths, o) end

	def _mkdir(paths, o)
		o[:mode] ||= 0744
		paths.map!{|v|get(v)}
		paths.each {|p|
			if File.exists?(p)
				o[:force] ? next : raise(Errno::EEXIST, "File exist -- #{p}")
			end

			stack = []
			until p == stack.last
				break if File.exists?(p)
				stack << p
				p = File.dirname(p)
			end

			stack.reverse.each do |path|
				Dir.mkdir(path)
				File.chmod(o[:mode], path)
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
		File.mkdir(p)
		begin blk.call(p) ensure Dir.delete(p) end if blk
		p
	end # def mktmpdir

	def home(user=nil) Dir.home end

	# make temp file
	# @see mktmpdir
	#
	# @param [Hash] o options
	# @return [String] path
	def mktmpfile(o={}, &blk) 
		p = _mktmpname(o) 
		begin blk.call(p) ensure File.delete(p) end if blk
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

	# rm file only
	#
	# @param [String] *paths support globbing
	# @return [nil]
	def rm(*paths) 
		glob(*paths) { |pa|
			next if not pa.exists?
			File.delete(pa.p)
		}
	end

	# rm directory only. still remove if directory is not empty.
	#
	# @param [String] *paths support globbing
	# @return [nil]
	def rmdir *paths
		glob(*paths) { |pa|
			raise Errno::ENOTDIR, "-- #{pa}" if not pa.directory?
			_rmdir(pa)
		}
	end

	# rm recusive, rm both file and directory
	#
	# @see rm
	# @return [nil]
	def rm_r(*paths)
		glob(*paths){ |pa|
			next if not pa.exists?
			pa.directory?  ? _rmdir(pa) : File.delete(pa.p)
		}
	end

	# rm_r(path) if condition is true
	#
	# @example
	#   Pa.rm_if '/tmp/**/*.rb' do |pa|
	#     pa.name == 'old'
	#   end
	#
	# @param [String] *paths support globbing
	# @yield [path]
	# @yieldparam [Pa] path
	# @yieldreturn [Boolean] rm_r path if true
	# @return [nil]
	def rm_if(*paths, &blk)
		glob(*paths) do |pa|
			rm_r pa if blk.call(pa)
		end
	end

	# I'm recusive 
	# param@ [Pa] path
	def _rmdir(pa, o={})
		return if not pa.exists?
		pa.each {|pa1|
			pa1.directory? ? _rmdir(pa1, o) : File.delete(pa1.p)
		}
		pa.directory? ? Dir.rmdir(pa.p) : File.delete(pa.p)
	end
	private :_rmdir

	# copy
	#
	# cp file dir
	#  cp 'a', 'dir' #=> dir/a 
	#  cp 'a', 'dir/a' #=> dir/a
	#
	# cp file1 file2 .. dir
	#  cp ['a','b'], 'dir' #=> dir/a dir/b
	#
	# @example
	#  cp '*', 'dir' do |src, dest, o|
	#    skip if src.name=~'.o$'
	#    dest.replace 'dirc' if src.name=="foo"
	#    yield  # use yield to do the actuactal cp work
	#  end
	#
	# @overload cp(src_s, dest, o)
	#   @param [Array<String>, String] src_s support globbing
	#   @param [String,Pa] dest
	#   @param [Hash] o option
	#   @option o [Boolean] :mkdir mkdir(dest) if dest not exists.
	#   @option o [Boolean] :verbose puts cmd when execute
	#   @option o [Boolean] :folsymlink follow symlink
	#   @option o [Boolean] :overwrite overwrite dest file if dest is a file
	#   @return [nil]
	# @overload cp(src_s, dest, o)
	#   @yield [src,dest,o]
	#   @return [nil]
	def cp(src_s, dest, o={}, &blk)
		srcs = glob(*Array.wrap(src_s))
		dest = Pa(dest)

		if o[:mkdir] and (not dest.exists?)
			mkdir dest
		end

		# cp file1 file2 .. dir
		if srcs.size>1 and (not dest.directory?)
			raise Errno::ENOTDIR, "dest not a directory when cp more than one src -- #{dest}"  
		end

		srcs.each do |src|
			dest1 = dest.directory? ? dest.join(src.b) : dest

			if blk
				blk.call src, dest1, o, proc{_copy(src, dest1, o)}
			else
				_copy src, dest1, o
			end

		end
	end


	# I'm recursive 
	#
	# @param [Pa] src
	# @param [Pa] dest
	def _copy(src, dest, o={})  
		raise Errno::EEXIST, "dest exists -- #{dest}" if dest.exists? and (not o[:overwrite])

		case type=src.type
		when "file", "socket"
			puts "cp #{src} #{dest}" if o[:verbose]
			File.copy_stream(src.p, dest.p)
		when "directory"
			begin
				mkdir dest
				puts "mkdir #{dest}" if o[:verbose]
			rescue Errno::EEXIST
			end
			each(src) { |pa|
				_copy(pa, dest.join(pa.b), o)
			}
		when "symlink"
			if o[:folsymlink] 
				_copy(src.readlink, dest) 
			else
				symln(src.readlink, dest, force: true)	
				puts "symlink #{src} #{dest}" if o[:verbose]
			end
		when "unknow"
			raise EUnKnownType, "Can't handle unknow type(#{:type}) -- #{src}"
		end

		# chmod chown utime
		src_stat = o[:folsymlink] ? stat(src) : lstat(src)
		begin
			chmod(src_stat.mode, dest)
			chown(src_stat.uid, src_stat.gid, dest)
			utime(src_stat.atime, src_stat.mtime, dest)
		rescue Errno::ENOENT
		end
	end # _copy
	private :_copy

	# move, use rename for same device. and cp for cross device.
	# @see cp
	#
	# @param [Hash] o option
	# @option o [Boolean] :verbose
	# @option o [Boolean] :mkdir
	# @option o [Boolean] :overwrite
	# @return [nil]
	def mv(src_s, dest, o={}, &blk)
		srcs = glob(*Array.wrap(src_s))
		dest = Pa(dest)

		if o[:mkdir] and (not dest.exists?)
			mkdir dest
		end

		# mv file1 file2 .. dir
		if srcs.size>1 and (not dest.directory?)
			raise Errno::ENOTDIR, "dest not a directory when mv more than one src -- #{dest}"  
		end

		srcs.each do |src|
			dest1 = dest.directory? ? dest.join(src.b) : dest

			if blk
				blk.call src, dest1, o, proc{_move(src, dest1, o)}
			else
				_move src, dest1, o
			end

		end
	end

	# I'm recusive
	#
	# _move "file", "dir/file"
	#
	# @param [Pa] src
	# @param [Pa] dest
	def _move(src, dest, o)
		raise Errno::EEXIST, "dest exists -- #{dest}" if dest.exists? and (not o[:overwrite])

		# overwrite. mv "dir", "dira" and 'dira' exists and is a directory. 
		if dest.exists? and dest.directory? 
				ls(src) { |pa|
					dest1 = dest.join(pa.b)
					_move pa, dest1, o
				}
				rm_r src

		else
			begin
				rm_r dest if o[:overwrite] and dest.exists?
				puts "rename #{src} #{dest}" if o[:verbose]
				File.rename(src.p, dest.p)
			rescue Errno::EXDEV # cross-device
				_copy(src, dest, o)
				rm_r src
			end

		end
	end # def _move
	private :_move


end
end
