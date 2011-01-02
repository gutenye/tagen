# methods_missing goto @pa

class Gile < File

	attr_reader :path

	def initialize path, flag="r"
		super(path, flag)
		@path = path
		@pa = Pa(path)
	end
	def method_missing(name, *args)
		@pa.__send__ name, *args
	end

	def rm *args
		close unless closed?
		Pa.rm @path, *args
	end

	alias oldeach each
	def each(*args, &blk)
		o = args.to_o
		o[:sep] ||= $/
		o[:limit] ||= -1
		method_args = [o[:sep], o[:limit]]
		__each(method(:oldeach), method_args, o, *args, &blk)
	end

	alias lines each

	alias oldchars chars
	def chars(*args, &blk)
		o = args.to_o
		__each(method(:oldchars), [], o, *args, &blk)
	end

	alias oldbytes bytes
	def bytes(*args, &blk)
		o = args.to_o
		__each(method(:oldbytes), [], o, *args, &blk)
	end

	alias oldcodepoints codepoints
	def codepoints(*args, &blk)
		o = args.to_o
		__each(method(:codepoints), [], o, *args, &blk)
	end

	def __each(method, method_args, o, *args, &blk)
		start = 0
		has_memo = false
		memo = []
		args.each do |arg|
			case arg
			when Fixnum
				start = arg
			else
				memo = arg
			end
		end
		
		method.call *method_args do |value|
			blk_rst = blk.call(value, start, memo)
			start+=1

			if not has_memo
				if o[:nil]
					memo << blk_rst
				else
					memo << blk_rst if not blk_rst.nil?
				end
			end
		end

		memo
	end
	def bytes(*args, &blk)
		o = args.to_o

		start = 0
		has_memo = false
		memo = []
		args.each do |arg|
			case arg
			when Fixnum
				start = arg
			else
				memo = arg
			end
		end
		
		oldbytes do |char|
			blk_rst = blk.call(char, start, memo)
			start+=1

			if not has_memo
				if o[:nil]
					memo << blk_rst
				else
					memo << blk_rst if not blk_rst.nil?
				end
			end
		end

		memo
	end

	def chars(*args, &blk)
		o = args.to_o
		o[:sep] = //
		each(*args, o, &blk)
	end

	def bytes(*args, &blk)
		 
	end
end
class << Gile
	def each(p, *args, &blk)
		open(p) {|f| return f.each(*args, &blk) }
	end

	def truncate path, size=0
		super(path, size)
	end

	def truncate_f path, size=0
		if !exists?(path)
			Pa.touch(path)
		else
			truncate(path, size)
		end
	end

end

module Kernel
	def gopen(path, flag="r", &blk) Gile.open(path, flag, &blk) end
	def gread(path) open(path){|f| return f.read} end
	def gwrite(path, text) open(path, "w"){|f| f.write(text)} end
	def gappend(path, text) open(path, "a"){|f| f.write(text)} end
	private :gopen, :gread, :gwrite, :gappend
end

