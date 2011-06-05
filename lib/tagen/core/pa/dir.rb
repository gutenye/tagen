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
	# @note raise Errno::ENOTDIR, Errno::ENOENT  
	#
	# @example
	#   each '.' do |pa|
	#     p pa.path #=> "foo" not "./foo"
	#   end
	#   # => '/home' ..
	#
	#  each('.', error: true).with_object([]) do |(pa,err),m|
	#    ...
	#  end
	#
	# @overload each(path=".", o={})
	#   @param [String,Pa] path
	#   @prarm [Hash] o
	#   @option o [Boolean] :nodot (false) include dot file
	#   @option o [Boolean] :nobackup (false) include backup file
	#   @option o [Boolean] :error (false) yield(pa, err) instead of raise Errno::EPERM when Dir.open(dir)
	#   @return [Enumerator<Pa>]
	# @overload each(path=".", o={})
	#   @yieldparam [Pa] path
	#   @return [nil]
	def each(*args, &blk) 
		return Pa.to_enum(:each, *args) unless blk

		(path,), o = args.extract_options
		path = path ? get(path) : "."
		raise Errno::ENOENT, "`#{path}' doesn't exists."  unless File.exists?(path)
		raise Errno::ENOTDIR, "`#{path}' not a directoyr."  unless File.directory?(path)

		begin
			dir = Dir.open(path)
		rescue Errno::EPERM => err
		end
		raise err if err and !o[:error]

		while (entry=dir.read)
			next if %w(. ..).include? entry
			next if o[:nodot] and entry=~/^\./
			next if o[:nobackup] and entry=~/~$/

			# => "foo" not "./foo"
			pa = path=="." ? Pa(entry) : Pa(File.join(path, entry))
			if o[:error]
				blk.call pa, err  
			else
				blk.call pa
			end
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
	#   @yieldparam [Pa] pa
	#   @yieldparam [String] relative relative path
	#   @yieldparam [Errno::ENOENT,Errno::EPERM] err 
	#   @return [nil]
	def each_r(*args, &blk)
		return Pa.to_enum(:each_r, *args) if not blk

		(path,), o = args.extract_options
		path ||= "."

		_each_r(path, "", o, &blk)
	end

	# @param [String] path
	def _each_r path, relative, o, &blk
		o.merge!(error: true)
		Pa.each(path, o) do |pa1, err|
			relative1 = Pa.join(relative, pa1.b) 

			blk.call pa1, relative1, err

			if pa1.directory?
				_each_r(pa1.p, relative1, o, &blk)
			end
		end
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
		each_r(*args).with_object([]){|pa,m| m<<pa.base}
	end

end
end
