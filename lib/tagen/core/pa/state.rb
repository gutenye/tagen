module Pa::State
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
		rescue Errno::ENOENT
			false
		end
	end
end
