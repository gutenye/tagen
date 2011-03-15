=begin
== ls family
	* Dir[*path] _support globbing_
	* Pa.glob(*path,o),(){} _support globbing with option and block_
	* each(path),(){} each_r(),(){} _support Enumerator. not support globbing_
	* ls(path) ls_r(path) _sample ls. not support globbing._
=== Example	
	each(".") do |pa|
	  p pa
	end

	each(".").with_index(2){|pa,i| ... }
=end
class Pa
module ClassMethods::Dir

	# path globbing, exclude '.' '..' for :dotmatch
	# @note glob is * ** ? [set] {a,b}
	#
	# @overload glob(*paths, o={})
	# 	@param [String] path
	# 	@param [Hash] o option
	# 	@option o [Boolean] :dotmatch glob not match dot file by default.
	# 	@option o [Boolean] :pathname wildcard doesn't match /
	# 	@option o [Boolean] :noescape makes '\\' ordinary
	# 	@return [Array<Pa>] 
	# @overload glob(*paths, o={})
	#   @yieldparam [Pa] path
	#   @return [nil]
	def glob(*args, &blk)
		paths, o = args.extract_options
		paths.map!{|v|get(v)}

		flag = 0
		o.each do |option, value|
			flag |= File.const_get("FNM_#{option.upcase}") if value
		end

		ret = Dir.glob(paths, flag)

		# delete . .. for '.*'
		ret.tap{|v|v.delete(*%w(. ..))}
		ret.map!{|v|Pa(v)}

		if blk
			ret.each {|pa|
				blk.call pa
			}
		else
			ret
		end
	end

	# is directory empty?
	#
	# @param [String] path
	# @return [Boolean]
	def empty?(path) Dir.entries(get(path)).empty? end

	# traverse directory 
	# @note return if not a directory.
	#
	# @example
	#   each '.' do |pa|
	#     p pa.path #=> "foo" not "./foo"
	#   end
	#   # => '/home' ..
	#
	# @overload each(path=".", o={})
	#   @param [String,Pa] path
	#   @prarm [Hash] o
	#   @option o [Boolean] :nodot (nil) include dot file
	#   @option o [Boolean] :nobackup (nil) include backup file
	#   @return [Enumerator<Pa>]
	# @overload each(path=".", o={})
	#   @yieldparam [Pa] path
	#   @return [nil]
	def each(*args, &blk) 
		return Pa.to_enum(:each, *args) if not blk

		(path,), o = args.extract_options
		path ||= "."
		return if not File.directory?(path)

		Dir.foreach path do |name|
			next if %w(. ..).include? name
			next if o[:nodot] and name=~/^\./
			next if o[:nobackup] and name=~/~$/

			# => "foo" not "./foo"
			blk.call path=="." ? Pa(name) : Pa(File.join(path, name))
		end
	end

	# each with recursive
	# @see each
	#
	# * each_r() skip Exception
	# * each_r(){pa, err}
	#
	# @overload each_r(path=".", o={})
	#   @return [Enumerator<Pa>]
	# @overload each_r(path=".", o={})
	#   @yield [pa,err]
	#   @return [nil]
	def each_r(*args, &blk)
		return Pa.to_enum(:each_r, *args) if not blk

		(path,), o = args.extract_options
		path ||= "."

		_each_r(path, "", o, &blk)
	end

	# @param [String] path
	def _each_r path, relative, o, &blk
		Pa.each(path, o) do |pa1|
			relative1 = Pa.join(relative, pa1.b) 
			blk.call pa1, relative1
			if pa1.directory?
				_each_r(pa1.p, relative1, o, &blk)
			end
		end
		rescue Errno::ENOENT, Errno::EPERM => e
			blk.call pa, relative, e 
	end
	private :_each_r

	# list directory contents
	# @see each
	#
	# @return [Array<String>]
	def ls(*args)
		each(*args).with_object([]){|pa,m| m<<pa.b}
	end

	# ls with recursive
	# @see each
	#
	# @return [Array<String>]
	def ls_r(*args)
		each_r(*args).with_object([]){|pa,m| m<<pa.b}
	end

end
end
