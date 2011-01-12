require "time"
require "date"
require_relative "core/kernel"
require_relative "core/gile"
require_relative "core/pa"
require_relative "core/ta"
require_relative "core/formatter"


# class Object
# 	.xx and #xx
# class Module
# 	Mod.xx Cls.xx 
# class Class
#   Cls.xx
#
# module Kernel
# 	builtin-method is private in Kernel
#
class Module #¤module

	alias :original_append_features :append_features
	# after include module, convert methods in  ClassMethods to class methods.
	# @see ruby-core Module#append_features
	#
	# @example
	#   module Guten
	#   	module ClassMethods
	#   		def a; end     # after include Guten, `a` becomes a class method.
	#   	end
	#	  end
	#  
	#   class Tag
	#   	include Guten
	#	  end
	#	  Tag.a
	#
	def append_features base
		original_append_features base
		base.extend const_get(:ClassMethods) if const_defined?(:ClassMethods)
	end

		# an abstract method is 
		#   def myabstract
		#     raise NotImplementedError
		#   end
		def abstract_method *names
module_eval do
	names.each do |name|
		next if method_defined? name
		define_method(name) {raise NotImplementedError}
	end
end
		end
end #class Module

# class Object 
class Object
	# builtin: Array#to_ary
	def to_array
		case self
		when Array
			self
		when NilClass
			[]
		else
			[self]
		end
	end

	# :force or name:1
	def to_o *defaults
		o1 = __parse_o(defaults)
		o2 = __parse_o(self)
		o1 + o2
	end

	def __parse_o obj
		case obj
		when Array
			# name:1
			o1 = Hash === obj.last ? obj.pop : {}
			# :force :_force
			rst = obj.find_all!{|v| Symbol===v}
			o2={}
			rst.each do |k|
				v = true
				if k=~/^_/
					k = k[1..-1].to_sym
					v = false
				end
				o2[k] = v
			end
			o1+o2
		when Hash
			obj
		end
	end
end

# 'try' not works with rails
unless defined? Rails
class NilProxy
	require "singleton"
	include Singleton
	def method_missing(*a,&b) end
end
class Object
	def try() self end
end
class NilClass 
	def try
		NilProxy.instance
	end
end
end

# Numeric + Comparable 
# Integer 
# 	Fixnum
# 	Bignum
# Float   
# Complex	
# Rational
class Numeric #¤numeric
	# equivalent to a.fdiv(b).ceil
	def div2 num
		d, m = divmod(num)
		d + (m==0 ? 0 : 1)
	end
end
class Float #¤float
	# 1.1 => [1, 0.1]
	# 1.1 -1 => 0.10000000000000009
	def ab
		a = self.to_i
		b = self.to_s.sub(/[^.]*/, "0").to_f
		[a, b]
	end
	def a; ab[0] end
	def b; ab[1] end
end

class String #¤string
	# conflict with others
	# 	to_a  --  Array()
	#   include Enumerable -- Array()
	class << self
		def digits; "0123456789" end
		def hexdigits; "01234567890ABCDEF" end
		def octdigits; "01234567" end
		def uppercase; "ABCDEFGHIJKLMNOPQRSTUVWXYZ" end
		def lowercase; "abcdefghijklmnopqrstuvwxyz" end
		def letters; uppercase+lowercase end
	end
	alias :len :length

	# for Socket_addr. alse see #unaddr
	def addr() self.split(".").map{|v|v.to_i}.pack("CCCC") end
	def unaddr() self.unpack("CCCC").join(".") end

end # class String
class MatchData #¤matchdata
	def to_hash(*keys)
		keys.zip(to_a[1..-1]).to_hash
	end
end

module Enumerable  #¤enumrable
	# @gach
	# args@ 10 memo 
	# o@ :reverse
	#
	def gach *args, &blk
		# can't use to_o. wie memo is {} 
		
		# handle args 
		start = 0
		has_memo = false
		memo = Array===self ? [] : self.dup # [] or {..}.dup
		o = {}
		args.each do |arg|
			case arg
			when Fixnum
				start = arg
			when Symbol
				o[arg] = true
			else
				memo = arg
				has_memo = true
			end
		end

		obj = self.dup
		obj = obj.reverse if o[:reverse]

		if Array === self
			obj.each_with_index do |v,i| 
				begin
					blk_rst = blk.call(v, i+start, memo) 
				rescue ArgumentError  # for gach(&:to_s)
					blk_rst = blk.call(v) 
				end

				unless has_memo
					if o[:nil] then memo << blk_rst else memo << blk_rst if not blk_rst.nil?  end
				end

			end
		elsif Hash === self
			each do |k,v| 
				blk.call(k, v, memo)
			end
		end

		memo
	end # def gach
	def gach! *args,&blk
		self.replace gach(*args, &blk)
	end
end #module Enumerable
class Array  #¤ary
	alias :len :length
	alias :append :push

	# [ [1,2], [3,4] ].to_hash
	def to_hash 
	# can't use Hash[self] -- SystemStackError
		ret = {}
		each do |k,v|
			ret[k]=v
		end
		ret
	end # def to_hash

	def find_all! &blk
		ret, newself = [], []
		self.each do |v|
			blk.call(v) ?  ret << v : newself << v
		end
		self.replace newself
		ret
	end

	# original_delete(value, &blk)
	# delete(*values, &blk)
	alias :original_delete :delete
	def delete *values, &blk
		indexs = []
		values.each do |v|
			indexs << original_delete(v, &blk)
		end
		values.len==1 ? indexs[0] : indexs
	end

	alias :original_delete_at :delete_at
	def delete_at *indexs, &blk
		values = []
		indexs.each do |i|
			values << original_delete_at(i, &blk)
		end
		indexs.len==1 ? values[0] : values
	end
end # class Array
class Hash  #¤hash
	alias :+ :merge
	alias :len :length

	alias :original_delete :delete
	def delete *keys, &blk
		values = []
		keys.each do |k|
			values << original_delete(k, &blk)
		end
		keys.len==1 ? values[0] : values
	end

end # class Hash
class Struct
	alias :len :length
end

class IO #¤io
	# conflict
	# puts not work for Socket
	alias fd fileno
end # class IO
class File #¤file
	class Stat
		alias inode ino
	end
end

class Time #¤time
	# an alias for Time.now.to_f
	def self.time; now.to_f end
end # class Time

module Marshal #¤marshal
class <<self
	alias :original_load :load
	alias :original_dump :dump

	# obj@ str io Pa
	def load(obj) original_load Pa===obj ? gread(obj.p) : obj end

	# obj@ io path
	# dump(con, [obj], limit=-1)
	def dump(con, *args)
		case args[0]
		when String, Pa
			path = String===args[0] ? args[0] : args[0].p
			open(path, "wb"){|f| f.write(original_dump(con))}
		else
			original_dump con, *args
		end
	end
end
end
