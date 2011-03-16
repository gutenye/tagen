class Pa
module ClassMethods::State

	# @see File.chmod
	def chmod(mode, *paths) paths.map!{|v|get(v)}; File.chmod(mode, *paths) end

	# @see File.lchmod
	def lchmod(mode, *paths) paths.map!{|v|get(v)}; File.lchmod(mode, *paths) end

	# @see File.chown
	def chown(user, group=nil, *paths) paths.map!{|v|get(v)}; File.chown(user, group, *paths) end

	# @see File.lchown
	def lchown(user, group=nil, *paths) paths.map!{|v|get(v)}; File.lchown(user, group, *paths) end

	# @see File.utime
	def utime(atime, mtime, *paths) paths.map!{|v|get(v)}; File.utime(atime, mtime, *paths) end


	# get file type
	#
	# file types:
	#   "chardev" "blockdev" "symlink" ..
	#
	# @param [String] path
	# @return [String] 
	def type(path)
		case (t=File.ftype(get(path)))
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


	# is path a mountpoint?
	#
	# @param[String] path
	# @return [Boolean]
	def mountpoint? path
		path=get(path)
		begin
			stat1 = File.lstat(path)
			stat2 = File.lstat(File.join(path, '..'))
			stat1.dev == stat2.dev && stat1.ino == stat2.ino || stat1.dev != stat2.dev
		rescue Errno::ENOENT
			false
		end
	end
end

module State
	def chmod(mode); File.chmod(mode, path) end
	def lchmod(mode); File.lchmod(mode, path) end
	def chown(uid, gid=nil); File.chown(uid, gid, path) end
	def lchown(uid, gid=nil); File.lchown(uid, gid, path) end
	def utime(atime, mtime); File.utime(atime, mtime, path) end
end

end


